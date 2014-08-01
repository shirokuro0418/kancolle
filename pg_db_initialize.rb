# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(__dir__ + "/lib")

require 'pg'
require "kancolle"
require 'date'

include Kancolle

start_time = Time.now

db = PG::connect(:host => "localhost", :user => "shirokuro11", :dbname => "kancolle", :port => 8989)

dirs = Kanmusu::dir
stage = FindEntryFile::parse_for_dir(dirs.shift)
dirs.each.with_index(1) do |dir, i|
  stage.push(FindEntryFile::parse_for_dir(dir))
end
len = stage.length

# CREATE TABLE
begin
  re =  db.exec "select * from pg_tables where not tablename like 'pg%' order by tablename;"
  if !re.select{|table| table["tablename"] == "entry_files"}.empty?
    db.exec "DROP TABLE entry_files;"
  end

  Data_type = "id SERIAL PRIMARY KEY,date TIMESTAMP UNIQUE NOT NULL,ids VARCHAR(100) NOT NULL,map VARCHAR(100) NOT NULL," +
    "lvs VARCHAR(100) NOT NULL,lost_fuels VARCHAR(100) NOT NULL,lost_bulls VARCHAR(100) NOT NULL,lost_bauxites VARCHAR(100) NOT NULL," +
    "route VARCHAR(100) NOT NULL,names VARCHAR(100) NOT NULL,hantei VARCHAR(100) NOT NULL,slots VARCHAR(500) NOT NULL," +
    "rengeki VARCHAR(100) NOT NULL,battle_forms VARCHAR(100) NOT NULL,seiku VARCHAR(100) NOT NULL,exps VARCHAR(100) NOT NULL," +
    "now_exps VARCHAR(100) NOT NULL,now_exps_end VARCHAR(100) NOT NULL,got_fuel INTEGER,got_bull INTEGER NOT NULL," +
    "got_steel INTEGER NOT NULL,got_bauxisite INTEGER NOT NULL," +
    "start VARCHAR(100),file VARCHAR,start2 VARCHAR(100),slotitem_member VARCHAR(100)," +
    "end_slotitem_member VARCHAR(100),port VARCHAR(100),end_port VARCHAR(100)"
  db.exec "CREATE TABLE entry_files (#{Data_type});"

  # INSERT
  DbConnection::insert(stage, db)

  db.exec "CREATE INDEX emtry_files_date ON entry_files(date);"
rescue => e
  puts "#{e}"
ensure
  db.close
end

puts "処理時間：#{Time.now-start_time}s"
