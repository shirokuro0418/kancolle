# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(__dir__ + "/lib")

require "rubygems"
require "kancolle"

include Kancolle

start_time = Time.now

# データ更新
DbConnection::insert_newrest

if ARGV[0].nil?
  day = Date.today
else
  day = Date.today - ARGV[0].to_i
end

stage = DbConnection::sql "SELECT * FROM entry_files " +
  "WHERE date BETWEEN '#{day}' AND '#{day+1}'"

puts "#{day}の消費"
puts "出撃回数：#{stage.length}"
puts "燃料：#{stage.lost_fuels.flatten.inject(:+)}"
puts "弾薬：#{stage.lost_bulls.flatten.inject(:+)}"
puts "ボキ：#{stage.lost_bauxites.flatten.inject(:+)}"

puts "処理時間 #{Time.now - start_time}s"
