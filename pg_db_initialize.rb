# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(__dir__ + "/lib")

require 'pg'
require "kancolle"
require 'date'

include Kancolle

start_time = Time.now

db = PG::connect(:host => "localhost", :user => "shirokuro11", :dbname => "kancolle", :port => 8989)

#begin
dirs = Kanmusu::dir
stage = FindEntryFile::parse_for_dir(dirs.shift)
dirs.each.with_index(1) do |dir, i|
  stage.push(FindEntryFile::parse_for_dir(dir))
end
len = stage.length

re =  db.exec "select * from pg_tables where not tablename like 'pg%' order by tablename;"
if !re.select{|table| table["tablename"] == "entry_files"}.empty?
  db.exec "DROP TABLE entry_files;"
end

# CREATE TABLE
Data_type = "id SERIAL PRIMARY KEY,date TIMESTAMP,ids VARCHAR(100),map VARCHAR(100),lvs VARCHAR(100)," +
  "lost_fuels VARCHAR(100),lost_bulls VARCHAR(100),lost_bauxites VARCHAR(100),route VARCHAR(100)," +
  "names VARCHAR(100),hantei VARCHAR(100),slots VARCHAR(500),rengeki VARCHAR(100),battle_forms VARCHAR(100)," +
  "seiku VARCHAR(100),exps VARCHAR(100),now_exps VARCHAR(100),now_exps_end VARCHAR(100)," +
  "got_fuel INTEGER, got_bull INTEGER, got_steel INTEGER, got_bauxisite INTEGER"
db.exec "CREATE TABLE entry_files (#{Data_type});"

# INSERT
begin
  db.exec "BEGIN"
  print "insert準備中：計#{len}中\n"
  stage.entry_files.each_with_index do |entry_file, i|
    print "#{i} " if i % 10 == 0
    ins_cal = ""
    ins_val = ""
    entry_file.to_db.each do |key, value|
      ins_cal += "#{key},"
      if value.nil?
        ins_val += 'null,'
      else
        # puts "'#{value.to_s}',".length if key == "slots" &&  "'#{value.to_s}',".length > 255
        ins_val += "'#{value.to_s}',"
      end
    end
    ins_cal.sub!(/,$/, '')
    ins_val.sub!(/,$/, '')
    db.exec "INSERT INTO entry_files(#{ins_cal}) VALUES (#{ins_val});"
  end
  puts "\n実行"
  db.exec "COMMIT"

rescue => e
  puts "errer: #{e.message}"
  db.exe "ROLLBACK" if db
ensure
  db.close
end

puts "処理時間：#{Time.now-start_time}s"
