# -*- coding: utf-8 -*-
require 'pg'

module Kancolle
  class DbConnection
    def self.connect
      PG::connect(:host => "localhost", :user => "shirokuro11", :dbname => "kancolle", :port => 8989)
    end
    def self.all
      db = PG::connect(:host => "localhost", :user => "shirokuro11", :dbname => "kancolle", :port => 8989)

      columns =
        db.exec "SELECT column_name FROM information_schema.columns WHERE table_name = 'entry_files' ORDER BY ordinal_position;"
      fields = Array.new
      columns.each do |row|
        fields << row["column_name"]
      end

      entry_files = Array.new
      db.exec("select * from entry_files").each do |row|
        entry = Hash.new
        fields.each do |column|
          entry[column] = row[column] if column != "id"
        end
        entry_files.push DbEntryFile.new(entry)
      end
      return DbEntryFiles.new(entry_files.sort{|a,b| a.date<=>b.date})
    end
    def self.between_days(s_day, e_day)
      DbConnection::sql "SELECT * FROM entry_files WHERE date BETWEEN '#{s_day}' AND '#{e_day}'"
    end
    def self.today
      day = Date.now
      DbConnection::sql "SELECT * FROM entry_files WHERE date BETWEEN '#{day}' AND '#{day+1}'"
    end
    def self.sql(sql)
      db = PG::connect(:host => "localhost", :user => "shirokuro11", :dbname => "kancolle", :port => 8989)

      columns =
        db.exec "SELECT column_name FROM information_schema.columns WHERE table_name = 'entry_files' ORDER BY ordinal_position;"
      fields = Array.new
      columns.each do |row|
        fields << row["column_name"]
      end

      entry_files = Array.new
      db.exec("#{sql}").each do |row|
        entry = Hash.new
        fields.each do |column|
          entry[column] = row[column] if column != "id"
        end
        entry_files.push DbEntryFile.new(entry)
      end
      return EntryFiles.new(entry_files.sort{|a,b| a.date<=>b.date})
    end
    def self.insert_newrest(dir = nil)
      dir = "/Users/shirokuro11/Documents/koukai_nisshi/data/json/json" if dir.nil?

      db = self.connect

      begin
        select = db.exec "SELECT date FROM entry_files ORDER BY date DESC LIMIT 1"
        last_day = nil
        select.each do |row|
          last_day = Time.parse(row["date"])
        end

        insert_entry_files = FindEntryFile::parse_for_dir(dir, last_day)

        self.insert(insert_entry_files, db, false)

      rescue => e
        puts "errer: #{e.message}"
        db.exec "ROLLBACK" if db
      ensure
        db.close
      end
    end
    def self.insert(entry_files, db, outputs = true)
      begin
        db.exec "BEGIN"
        print "insert準備中：計#{entry_files.length}中\n" if outputs
        entry_files.entry_files.each_with_index do |entry_file, i|
          print "#{i} " if i % 10 == 0 && outputs
          ins_cal = ""
          ins_val = ""
          entry_file.to_db.each do |key, value|
            ins_cal += "#{key},"
            if value.nil?
              ins_val += 'null,'
            else
              ins_val += "'#{value.to_s}',"
            end
          end
          ins_cal.sub!(/,$/, '')
          ins_val.sub!(/,$/, '')
          db.exec "INSERT INTO entry_files(#{ins_cal}) VALUES (#{ins_val});"
        end
        puts "\n実行" if outputs
        db.exec "COMMIT"

      rescue => e
        puts "errer: #{e.message}"
        db.exec "ROLLBACK" if db
      end
    end
  end
end
