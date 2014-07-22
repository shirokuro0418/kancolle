# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(__dir__ + "/lib")

require "rubygems"
require "kancolle"

include Kancolle

stage = FindEntryFile::parse_for_dir
start_time = Time.now

if ARGV[0].nil?
  puts "今日の消費"
  s = stage.today
  puts "出撃回数：#{s.length}"
  puts "燃料：#{s.lost_fuels.flatten.inject(:+)}"
  puts "弾薬：#{s.lost_bulls.flatten.inject(:+)}"
  puts "ボキ：#{s.lost_bauxites.flatten.inject(:+)}"
else
  puts "#{ARGV[0]}日前の消費"
  s = stage.day(Date.today-ARGV[0].to_i)
  puts "出撃回数：#{s.length}"
  puts "燃料：#{s.lost_fuels.flatten.inject(:+)}"
  puts "弾薬：#{s.lost_bulls.flatten.inject(:+)}"
  puts "ボキ：#{s.lost_bauxites.flatten.inject(:+)}"
end

puts "処理時間 #{Time.now - start_time}s"
