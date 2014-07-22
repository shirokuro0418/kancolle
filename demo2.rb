# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(__dir__ + "/lib")

require "rubygems"
require "kancolle"

include Kancolle

stage = FindEntryFile::parse_for_dir(ARGV[0])
start_time = Time.now
puts "今日の消費"
puts "燃料：#{stage.today.lost_fuels.flatten.inject(:+)}"
puts "弾薬：#{stage.today.lost_bulls.flatten.inject(:+)}"
puts "ボキ：#{stage.today.lost_bauxites.flatten.inject(:+)}"

p "処理 #{Time.now - start_time}s"
