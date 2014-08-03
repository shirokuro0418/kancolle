# -*- coding: utf-8 -*-
# 遠征の得たアイテムのデータ

$LOAD_PATH.unshift("/Users/shirokuro11/program/kancolle/lib")

require "kancolle"
require 'date'

include Kancolle

start_time = Time.now

TABLE_ENSEI   = "ensei_result"
ENSEI_type = "id SERIAL PRIMARY KEY, ship_id INTEGER[] NOT NULL," +
  "date          TIMESTAMP UNIQUE NOT NULL," +
  "clear_result  INTEGER NOT NULL," +
  "get_exp       INTEGER NOT NULL," +
  "member_exp    INTEGER NOT NULL," +
  "get_ship_exp  INTEGER[] NOT NULL," +
  "maparea_name  CHARACTER(20) NOT NULL," +
  "detail        VARCHAR NOT NULL," +
  "quest_name    CHARACTER(20) NOT NULL," +
  "quest_level   INTEGER NOT NULL," +
  "get_material  INTEGER[] NOT NULL," +
  "item1_id INTEGER," +
  "count_item1 INTEGER," +
  "item2_id INTEGER," +
  "count_item2 INTEGER," +
  "FOREIGN KEY (item1_id) REFERENCES item(id)," +
  "FOREIGN KEY (item2_id) REFERENCES item(id)"
TABLE_ITEM = "item"
ITEM_type = "id INTEGER PRIMARY KEY, item_name CHARACTER(20)"

TABLE_NAMES = [[TABLE_ENSEI, ENSEI_type], [TABLE_ITEM, ITEM_type]]

db = DbConnection::connect
dirs = Kanmusu::dir

# begin
begin
  # CREATE TABLE
  re =  db.exec "select * from pg_tables where not tablename like 'pg%' order by tablename;"
  TABLE_NAMES.each do |table_name|
    if !re.select{|table| table["tablename"] == table_name[0]}.empty?
      db.exec "DROP TABLE #{table_name[0]};"
    end
  end
  TABLE_NAMES.reverse_each do |table_name|
    db.exec "CREATE TABLE #{table_name[0]} (#{table_name[1]});"
  end

  db.exec "BEGIN"
  db.exec "INSERT INTO item(id, item_name) VALUES (-1, null);"
  db.exec "INSERT INTO item(id, item_name) VALUES (1, '高速修理剤');"
  db.exec "INSERT INTO item(id, item_name) VALUES (2, '高速建造剤');"
  db.exec "INSERT INTO item(id, item_name) VALUES (3, '開発資材');"
  db.exec "INSERT INTO item(id, item_name) VALUES (10, '家具箱（小）');"
  db.exec "INSERT INTO item(id, item_name) VALUES (11, '家具箱（中）');"
  db.exec "INSERT INTO item(id, item_name) VALUES (12, '家具箱（大）');"
  db.exec "COMMIT"

  f = Array.new
  dirs.each do |dir|
    Dir.open(dir) do |idir|
      idir.each do |file|
        if file =~ /MISSION_RESULT.json$/
          f.push idir.path + "/" + file
        end
      end
    end
  end
  DbConnection::insert_ensei(f, db)

rescue => e
  puts "#{e}"
ensure
  db.close
end

puts "処理時間：#{Time.now-start_time}s"
