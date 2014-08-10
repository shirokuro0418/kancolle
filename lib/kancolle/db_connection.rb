# -*- coding: utf-8 -*-
require 'pg'

module Kancolle
  class DbConnection
    # conection
    def self.connect
      PG::connect(:host => "localhost", :user => "shirokuro11", :dbname => "kancolle", :port => 19190)
    end

    ## create
    def self.create_talbe(table_name, type)
      db = DbConnection::connect
      unless (db.exec "select tablename from pg_tables where tablename = '#{table_name.downcase}';").values.empty?
        db.exec "DROP TABLE #{table_name.downcase}"
      end

      db.exec "CREATE TABLE #{table_name} (#{type});"
    end

    ## select
    # entry_file
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
    def self.between_days(s_day, e_day)
      DbConnection::sql "SELECT * FROM entry_files WHERE date BETWEEN '#{s_day}' AND '#{e_day}'"
    end
    def self.today
      day = Date.today
      DbConnection::sql "SELECT * FROM entry_files WHERE date BETWEEN '#{day}' AND '#{day+1}'"
    end
    # ensei
    def self.all_ensei
      db = self.connect

      ensei_files = Array.new
      db.exec("SELECT * FROM ensei_result").each do |row|
        entry = Hash.new
        row.each do |column, value|
          entry[column] = value if column != "id"
        end
        ensei_files.push DbEnseiFile.new(entry)
      end
      return DbEnseiFiles.new(ensei_files.sort{|a,b| a.date<=>b.date})
    end
    def self.sql_ensei(sql)
      db = self.connect

      columns =
        db.exec "SELECT column_name FROM information_schema.columns WHERE table_name = 'ensei_result' ORDER BY ordinal_position;"
      fields = Array.new
      columns.each do |row|
        fields << row["column_name"]
      end

      ensei_files = Array.new
      db.exec("#{sql}").each do |row|
        ensei = Hash.new
        fields.each do |column|
          ensei[column] = row[column] if column != "id"
        end
        ensei_files.push DbEnseiFile.new(ensei)
      end
      return DbEntryFiles.new(ensei_files.sort{|a,b| a.date<=>b.date})
    end
    def self.today_ensei
      day = Date.today
      DbConnection::sql_ensei "SELECT * FROM ensei_result WHERE to_char(date, 'YYYY-MM-DD') = '#{day.to_s}';"
    end
    # start2 data
    def self.start2_mst_ship?(db, data)
      # カラム名 id, sortno, name, type_name
      !(db.exec "select * from mst_ship ship join mst_stype type on ship.stype = type.sortno WHERE ship.sortno = #{data};").values.empty?
    end
    def self.start2_mst_ship(db, key, data)
      # カラム名 id, sortno, name, type_name
      (db.exec "select ship.id, ship.sortno, ship.name, type.sortno type_id, type.name type_name from mst_ship ship join mst_stype type on ship.stype = type.sortno where ship.sortno = #{data};").each do |row|
        return row[key.to_s]
      end
    end

    # insert
    def self.insert_newrest(dir = nil)
      begin
        db = self.connect

        # entry_filesの更新
        select = db.exec "SELECT date FROM entry_files ORDER BY date DESC LIMIT 1"
        last_day = nil
        select.each do |row|
          last_day = Time::parse(row["date"])
        end
        Kanmusu::dir.each do |dir|
          insert_entry_files = FindEntryFile::parse_for_dir(dir, last_day)
          self.insert(insert_entry_files, db, false)
        end

        # ensei_resultの更新
        data = db.exec "SELECT date FROM ensei_result ORDER BY date DESC LIMIT 1"
        last_time = nil
        data.each{|row| last_time = Time::parse(row["date"])}
        last_day = Date::parse last_time.to_s

        ensei_dir = nil
        Kanmusu::dir.each do |dir|
          if dir == "/Users/shirokuro11/Documents/koukai_nisshi/data/json/json"
            ensei_dir = dir
            break
          elsif last_day <  Date.parse(Kanmusu::parse_time(dir).to_s)
            ensei_dir = dir
            break
          end
        end
        f = Array.new
        Dir.open(ensei_dir) do |idir|
          idir.each do |file|
            if file =~ /MISSION_RESULT.json$/
              if last_time < Kanmusu::parse_time(file)
                f.push idir.path + "/" + file
              end
            end
          end
        end
        DbConnection::insert_ensei(f, db, false) unless f.empty?

        # kanmususの更新
        last_time = Time.parse((db.exec "SELECT MAX(update_time) FROM kanmusus;").values[0][0])
        kanmusus_dir = nil
        Kanmusu::dir.each do |dir_name|
          if dir_name == Kanmusu::dir.last
            kanmusus_dir = dir_name
            break
          elsif last_time < Kanmusu::parse_time(dir_name)
            kanmusus_dir = dir_name
            break
          end
        end
        k_kanmusus = Hash.new
        k_last_time = nil
        Dir.open(kanmusus_dir) do |files|
          files.each do |file|
            if file =~ /_PORT.json$/ && last_time < Kanmusu::parse_time(file)
              # 更新情報取得
              file_full_path = kanmusus_dir + "/" + file
              port_json = nil
              open(file_full_path){|p| port_json = JSON::parse(p.read)}
              next if port_json["api_result"] != 1

              ## port_file内の艦娘の情報を取得
              k_last_time = Kanmusu::parse_time(file_full_path)
              port_json["api_data"]["api_ship"].each do |ship|
                k_kanmusus[ship["api_id"]] = {
                  :update_time => k_last_time,
                  :api_id      => ship["api_ship_id"],
                  :sortno      => ship["api_sortno"],
                  :now         => true
                }
              end
              # 名前と艦種を取得
              k_kanmusus.each do |id, value|
                # 内容変更予定
                if DbConnection::start2_mst_ship?(db, value[:sortno])
                  value[:name]    = DbConnection::start2_mst_ship(db, :name  , value[:sortno])
                  value[:type_id] = DbConnection::start2_mst_ship(db, :type_id, value[:sortno])
                  value[:type_name] = DbConnection::start2_mst_ship(db, :type_name, value[:sortno])
                end
                raise "errer :nameなし id:#{id}, value:#{value}" if value[:name].nil? 
              end
            end
          end
        end
        # puts "update false" if k_kanmusus.empty?
        unless k_kanmusus.empty?
          db.exec "UPDATE kanmusus SET now = 'false'"
          k_kanmusus.each do |id,v|
            # 今持っている艦か
            if v[:update_time] == k_last_time
              v[:now] = true
            else
              v[:now] = false
            end
            if (db.exec "SELECT * FROM kanmusus WHERE id = #{id}").values.empty?
              columns = "id,"
              datas   = ""

              datas += "#{id},"
              v.each do |column, data|
                columns += "#{column.to_s},"
                if data.is_a? Integer
                  datas += "#{data},"
                else
                  datas += "'#{data.to_s}',"
                end
              end
              # puts "insert"
              sql = "INSERT INTO kanmusus(#{columns.sub(/,$/,'')}) VALUES(#{datas.sub(/,$/,'')});"
            else
              sets = Array.new
              v.each do |column, data|
                if data.is_a? Integer
                  tmp_data = "#{data}"
                else
                  tmp_data = "'#{data.to_s}'"
                end
                sets.push "#{column}=#{tmp_data}"
              end
              # puts "update"
              sql = "UPDATE kanmusus SET #{sets.join(',')} WHERE id = #{id};"
            end

            DbConnection::run_sql sql
          end
        end
      rescue => e
        puts "errer: #{e.message}"
        db.exec "ROLLBACK" if db
      ensure
        db.close
      end
    end
    def self.insert(entry_files, db, outputs = true)
      to_arrays = ['map', 'lost_bauxites']
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
            elsif to_arrays.include? key
              ins_val += "'#{value.to_s.sub(/\[/,'{').sub(/\]/,'}')}',"
            else
              ins_val += "'#{value.to_s}',"
            end
          end
          ins_cal.sub!(/,$/, '')
          ins_val.sub!(/,$/, '')
          db.exec "INSERT INTO entry_files(#{ins_cal}) VALUES (#{ins_val});"
          if i % 1000 == 999
            puts "\n実行" if outputs
            db.exec "COMMIT"
            db.exec "BEGIN"
            print "insert準備中（#{i/1000+2}回目）：計#{entry_files.length}中\n" if outputs
          end
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
                when "練習航海"
                  data["quest_id"] = 1
                when "長距離練習航海"
                  data["item1_id"] = 1
                  data["quest_id"] = 2
                when "警備任務"
                  data["quest_id"] = 3
                when "対潜警戒任務"
                  data["item1_id"] = 1
                  data["item2_id"] = 10
                  data["quest_id"] = 4
                when "海上護衛任務"
                  data["quest_id"] = 5
                when "防空射撃演習"
                  data["item1_id"] = 10
                  data["quest_id"] = 6
                when "観艦式予行"
                  data["item1_id"] = 2
                  data["quest_id"] = 7
                when "観艦式"
                  data["item1_id"] = 2
                  data["item2_id"] = 3
                  data["quest_id"] = 8
                when "タンカー護衛任務"
                  data["item1_id"] = 10
                  data["item2_id"] = 1
                  data["quest_id"] = 9
                when "強行偵察任務"
                  data["item1_id"] = 1
                  data["item2_id"] = 2
                  data["quest_id"] = 10
                when "ボーキサイト輸送任務"
                  data["item1_id"] = 10
                  data["item2_id"] = 1
                  data["quest_id"] = 11
                when "資源輸送任務"
                  data["item1_id"] = 11
                  data["item2_id"] = 3
                  data["quest_id"] = 12
                when "鼠輸送作戦"
                  data["item1_id"] = 1
                  data["item2_id"] = 10
                  data["quest_id"] = 13
                when "包囲陸戦隊撤収作戦"
                  data["item1_id"] = 1
                  data["item2_id"] = 3
                  data["quest_id"] = 14
                when "囮機動部隊支援作戦"
                  data["item1_id"] = 12
                  data["item2_id"] = 3
                  data["quest_id"] = 15
                when "艦隊決戦援護作戦"
                  data["item1_id"] = 2
                  data["item2_id"] = 3
                  data["quest_id"] = 16
                when "敵地偵察作戦"
                  data["quest_id"] = 17
                when "航空機輸送作戦"
                  data["item1_id"] = 1
                  data["quest_id"] = 18
                when "北号作戦"
                  data["item1_id"] = 10
                  data["item2_id"] = 3
                  data["quest_id"] = 18
                when "潜水艦哨戒任務"
                  data["item1_id"] = 3
                  data["item2_id"] = 10
                  data["quest_id"] = 20
                when "北方鼠輸送作戦"
                  data["item1_id"] = 10
                  data["quest_id"] = 21
                when "艦隊演習"
                  data["quest_id"] = 22
                when "航空戦艦運用練習"
                  data["quest_id"] = 23
                when "敵母港空襲作戦"
                  data["item1_id"] = 1
                when "通商破壊作戦"
                  data["quest_id"] = 25
                when "敵母港空襲作戦"
                  data["item1_id"] = 1
                  data["quest_id"] = 26
                when "潜水艦通商破壊作戦"
                  data["item1_id"] = 3
                  data["item2_id"] = 10
                  data["quest_id"] = 27
                when "西方海域封鎖作戦"
                  data["item1_id"] = 3
                  data["item2_id"] = 11
                  data["quest_id"] = 28
                when "潜水艦派遣演習"
                  data["item1_id"] = 3
                  data["item2_id"] = 10
                  data["quest_id"] = 29
                when "潜水艦派遣作戦"
                  data["item1_id"] = 3
                  data["quest_id"] = 30
                when "海外艦との接触"
                  data["item1_id"] = 10
                  data["quest_id"] = 31
                when "MO作戦"
                  data["item1_id"] = 10
                  data["item2_id"] = 3
                  data["quest_id"] = 35
                when "水上機基地建設"
                  data["item1_id"] = 11
                  data["item2_id"] = 1
                  data["quest_id"] = 36
                when "東京急行"
                  data["item1_id"] = 10
                  data["quest_id"] = 37
                when "東京急行(弐)"
                  data["item1_id"] = 10
                  data["quest_id"] = 38
                when "遠洋潜水艦作戦"
                  data["item1_id"] = 1
                  data["item2_id"] = 11
                  data["quest_id"] = 39
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

    def self.run_sql(sql)
      begin
        db = DbConnection::connect
        db.exec "BEGIN"
        r = db.exec sql
        db.exec "COMMIT"
        return r
      rescue => e
        puts "errer: #{e.message}"
        db.exec "ROLLBACK" if db
      ensure
        db.close if db
      end
    end
  end
end
