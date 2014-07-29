# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(__dir__ + "/lib")

require 'sqlite3'
require "kancolle"
require 'date'

include Kancolle

start_time = Time.now

DB = "./db/kancolle.db"

File::delete DB

begin
  db = SQLite3::Database.new(DB)

  dirs = Kanmusu::dir
  stage = FindEntryFile::parse_for_dir(dirs.shift)
  dirs.each.with_index(1) do |dir, i|
    stage.push(FindEntryFile::parse_for_dir(dir))
  end
  len = stage.length

  cre = ""
  stage.entry_files[0].to_db.each do |key, value|
    cre += "#{key} text,"
  end
  cre.sub!(/,$/, '')

  db.execute "CREATE TABLE entry_file (id INTEGER PRIMARY KEY AUTOINCREMENT,#{cre});"

  db.transaction do
    print "insert実行中：計#{len}中　"
    stage.entry_files.each_with_index do |entry_file, i|
      print "#{i} "
      ins_cal = ""
      ins_val = ""
      entry_file.to_db.each do |key, value|
        ins_cal += "'#{key}',"
        if value.nil?
          ins_val += 'nil,'
        else
          ins_val += "'#{value.to_s}',"
        end
      end
      ins_cal.sub!(/,$/, '')
      ins_val.sub!(/,$/, '')
      db.execute "INSERT INTO entry_file(#{ins_cal}) VALUES (#{ins_val});"
    end
  end

rescue => e
  puts "errer: #{e.message}"
ensure
  db.close
end

puts "処理時間：#{Time.now-start_time}s"
