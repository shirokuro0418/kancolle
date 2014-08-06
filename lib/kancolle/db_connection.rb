# -*- coding: utf-8 -*-
require 'pg'

module Kancolle
  class DbConnection
    # conection
    def self.connect
      PG::connect(:host => "localhost", :user => "shirokuro11", :dbname => "kancolle", :port => 19190)
    end

    # select
    def self.all
      db = self.connect

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
      day = Date.today
      DbConnection::sql "SELECT * FROM entry_files WHERE date BETWEEN '#{day}' AND '#{day+1}'"
    end
    def self.sql(sql)
      db = self.connect

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
      return DbEntryFiles.new(entry_files.sort{|a,b| a.date<=>b.date})
    end

    # insert
    def self.insert_newrest(dir = nil)
      dir = "/Users/shirokuro11/Documents/koukai_nisshi/data/json/json" if dir.nil?
      db = self.connect

      begin
        select = db.exec "SELECT date FROM entry_files ORDER BY date DESC LIMIT 1"
        last_day = nil
        select.each do |row|
          last_day = Time::parse(row["date"])
        end
        insert_entry_files = FindEntryFile::parse_for_dir(dir, last_day)
        self.insert(insert_entry_files, db, false)

        data = db.exec "SELECT date FROM ensei_result ORDER BY date DESC LIMIT 1"
        last_time = nil
        data.each{|row| last_time = Time::parse(row["date"])}
        last_day = Date::parse last_time.to_s

        ensei_dir = nil
        Kanmusu::dir.each do |dir|
          if dir == "/Users/shirokuro11/Documents/koukai_nisshi/data/json/json"
            ensei_dir = dir
            break
          elsif last_day < Date.new(2014, File.basename(dir)[0,2].to_i, File.basename(dir)[3,2].to_i)
            ensei_dir = dir
            break
          end
        end
        f = Array.new
        Dir.open(ensei_dir) do |idir|
          idir.each do |file|
            if file =~ /MISSION_RESULT.json$/
              if last_time < Time::parse("#{File.basename(file)[0,10]} #{File.basename(file)[11,2]}:#{File.basename(file)[13,2]}:#{File.basename(file)[15,2]}")
                f.push idir.path + "/" + file
              end
            end
          end
        end
        DbConnection::insert_ensei(f, db, false) unless f.empty?

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
            elsif key == "map"
              ins_val += "'#{value.to_s.sub(/\[/,'{').sub(/\]/,'}')}',"
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
    def self.insert_ensei(ensei_files, db, output = true)
      redata_key = ["api_ship_id", "api_get_exp_lvup", "api_useitem_flag",
                    "api_get_item1", "api_get_item2", "api_member_lv", "api_quest_name",
                    "api_get_material"
                   ]
      begin
        puts "遠征INSERT準備中　#{ensei_files.length}回中：" if output
        db.exec "BEGIN"
        ensei_files.each_with_index do |ensei_file, i|
          print "#{i} " if i % 10 == 0 && output
          ensei = nil
          open(ensei_file) do |e|
            ensei = JSON::parse(e.read)
          end

          data = Hash.new
          tmp_file = File.basename(ensei_file)
          data["date"] = Time.local(tmp_file[0..3].to_i, tmp_file[5,2].to_i, tmp_file[8,2].to_i,
                                    tmp_file[11,2].to_i, tmp_file[13,2], tmp_file[15,2])
          ensei["api_data"].each do |key, value|
            if redata_key.include? key
              case key
              when "api_ship_id"
                v = value.clone
                v.shift
                data["ship_id"] = v
              when "api_quest_name"
                data[key.sub(/^api_/, '')] = value
                case value
                when "長距離練習航海"
                  data["item1_id"] = 1
                when "対潜警戒任務"
                  data["item1_id"] = 1
                  data["item2_id"] = 10
                when "防空射撃演習"
                  data["item1_id"] = 10
                when "観艦式予行"
                  data["item1_id"] = 2
                when "観艦式"
                  data["item1_id"] = 2
                  data["item2_id"] = 3
                when "タンカー護衛任務"
                  data["item1_id"] = 10
                  data["item2_id"] = 1
                when "強行偵察任務"
                  data["item1_id"] = 1
                  data["item2_id"] = 2
                when "ボーキサイト輸送任務"
                  data["item1_id"] = 10
                  data["item2_id"] = 1
                when "資源輸送任務"
                  data["item1_id"] = 11
                  data["item2_id"] = 3
                when "鼠輸送作戦"
                  data["item1_id"] = 1
                  data["item2_id"] = 10
                when "包囲陸戦隊撤収作戦"
                  data["item1_id"] = 1
                  data["item2_id"] = 3
                when "囮機動部隊支援作戦"
                  data["item1_id"] = 12
                  data["item2_id"] = 3
                when "艦隊決戦援護作戦"
                  data["item1_id"] = 2
                  data["item2_id"] = 3
                when "航空機輸送作戦"
                  data["item1_id"] = 1
                when "北号作戦"
                  data["item1_id"] = 10
                  data["item2_id"] = 3
                when "潜水艦哨戒任務"
                  data["item1_id"] = 3
                  data["item2_id"] = 10
                when "北方鼠輸送作戦"
                  data["item1_id"] = 10
                when "敵母港空襲作戦"
                  data["item1_id"] = 1
                when "潜水艦通商破壊作戦"
                  data["item1_id"] = 3
                  data["item2_id"] = 10
                when "西方海域封鎖作戦"
                  data["item1_id"] = 3
                  data["item2_id"] = 11
                when "潜水艦派遣演習"
                  data["item1_id"] = 3
                  data["item2_id"] = 10
                when "潜水艦派遣作戦"
                  data["item1_id"] = 3
                when "海外艦との接触"
                  data["item1_id"] = 10
                when "MO作戦"
                  data["item1_id"] = 10
                  data["item2_id"] = 3
                when "水上機基地建設"
                  data["item1_id"] = 11
                  data["item2_id"] = 1
                when "東京急行"
                  data["item1_id"] = 10
                when "東京急行(弐)"
                  data["item1_id"] = 10
                when "遠洋潜水艦作戦"
                  data["item1_id"] = 1
                  data["item2_id"] = 11
                else
                end
              when "api_useitem_flag"
              when "api_get_item1"
                data["count_item1"] = value["api_useitem_count"]
              when "api_get_item2"
                data["count_item2"] = value["api_useitem_count"]
              when "api_get_material"
                if value == -1
                  data[key.sub(/^api_/, '')] = [0,0,0,0]
                else
                  data[key.sub(/^api_/, '')] = value
                end
              when "api_get_exp_lvup"
              when "api_member_lv"
              else
                raise "errer: #{key}, #{value}"
              end
            else
              data[key.sub(/^api_/, '')] = value
            end
          end
          columns = ""
          values = ""
          data.each do |key, value|
            columns += key.to_s + ","
            if value.is_a? Integer
              values += value.to_s + ","
            elsif value.is_a? Array
              values += "'#{value.to_s.sub(/\[/, '{').sub(/\]/, '}')}',"
            else
              values += "'#{value.to_s}',"
            end
          end
          columns.sub!(/,$/, '')
          values.sub!(/,$/, '')

          db.exec "INSERT INTO ensei_result(#{columns}) VALUES (#{values});"
        end
        print "\n実行" if output
        db.exec "COMMIT"
      rescue => e
        puts "#{e}"
      end
    end
  end
end
