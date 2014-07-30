require 'pg'

module Kancolle
  class DbConnection
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
      return EntryFiles.new(entry_files.sort{|a,b| a.date<=>b.date})
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
    def self.isnsert(dir = nil)
      dir = "/Users/shirokuro11/Documents/koukai_nisshi/data/json/json" if dir.nil?

      db = connect
      select = db.exec "SELECT date FROM entry_files DESC LIMIT 1"
      p select
      exit
    end

    private
    def connect
      PG::connect(:host => "localhost", :user => "shirokuro11", :dbname => "kancolle", :port => 8989)
    end
  end
end
