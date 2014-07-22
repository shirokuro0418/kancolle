# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(__dir__ + "/lib")

require "rubygems"
require "kancolle"

include Kancolle

stage = FindEntryFile::parse_for_dir(ARGV[0])
start_time = Time.now

count_fuel  = 0
count_bull  = 0
count_bauxi = 0
count_syu   = 0

puts "１週間の出撃での消費"
puts "---------------------------------------------------------"
puts "|\t|日前\t|出撃回数\t|燃料\t|弾薬\t|ボーキ\t|"
puts "---------------------------------------------------------"
for i in 0..6
   s = stage.day(Date.today-i)

  d_fuel = s.lost_fuels.flatten.inject(:+)
  d_bull = s.lost_bulls.flatten.inject(:+)
  d_bauxi = s.lost_bauxites.flatten.inject(:+)
  count_fuel  += d_fuel
  count_bull  += d_bull
  count_bauxi += d_bauxi
  count_syu   += s.length
  print sprintf "|\t|%7d|%15d|%7d|%7d|%7d|\n", i, s.length, d_fuel, d_bull, d_bauxi
end
puts "---------------------------------------------------------"
print "|合計\t|"
print sprintf "\t|%15d|%7d|%7d|%7d|\n", count_syu, count_fuel, count_bull, count_bauxi
puts "---------------------------------------------------------"

puts "処理時間 #{Time.now - start_time}s"
