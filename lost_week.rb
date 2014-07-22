# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(__dir__ + "/lib")

require "rubygems"
require "kancolle"

include Kancolle

stage = FindEntryFile::parse_for_dir(ARGV[0])
start_time = Time.now
stage_week = stage.between_days(Date.today-7,Date.today)
puts "１週間の消費"
puts "出撃回数：#{stage_week.length}"
puts "燃料：#{stage_week.lost_fuels.flatten.inject(:+)}"
puts "弾薬：#{stage_week.lost_bulls.flatten.inject(:+)}"
puts "ボキ：#{stage_week.lost_bauxites.flatten.inject(:+)}"

p "処理 #{Time.now - start_time}s"
