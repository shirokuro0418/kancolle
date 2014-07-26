# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(__dir__ + "/lib")

require "kancolle"

include Kancolle

stage = FindEntryFile::parse_for_dir(ARGV[0]).extract_stage(5,4)
slots = stage.slots
bauxi = stage.lost_bauxites
names = stage.names

count_bauxi = 0
count_syutu = 0
max_bauxi = 0
min_bauxi = 20000

slots.each_with_index do |start_slots, i|
  if start_slots.to_s.include?("瑞雲12型") &&
      names[i].to_s.include?("鈴谷改") ||
      names[i].to_s.include?("熊野改") ||
      names[i].to_s.include?("利根改二") ||
      names[i].to_s.include?("筑摩改二")
    count_syutu += 1
    puts "#{count_syutu}回目"

    start_slots.each_with_index do |kanmusu_slot, j|
      count_bauxi += bauxi[i][j]
      if kanmusu_slot.to_s.include?("瑞雲12型")
        max_bauxi = [max_bauxi, bauxi[i][j]].max
        min_bauxi = [min_bauxi, bauxi[i][j]].min
      end
      if names[i][j].to_s.include?("鈴谷改") ||
          names[i][j].to_s.include?("熊野改") ||
          names[i][j].to_s.include?("利根改二") ||
          names[i][j].to_s.include?("筑摩改二")
        puts "名前：#{names[i][j]}、装備：#{kanmusu_slot.to_s}、ボーキ消費：#{bauxi[i][j]}"
      end
    end
    puts
  end
end
puts "出撃回数：#{count_syutu}、平均ボーキ：#{count_bauxi/count_syutu}"
puts max_bauxi
puts min_bauxi
