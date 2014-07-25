# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(__dir__ + "/lib")

require "rubygems"
require "kancolle"

include Kancolle

stage = FindEntryFile::parse_for_dir(ARGV[0])

slots = stage.extract_stage(5,4).slots
names = stage.extract_stage(5,4).names
bauxi = stage.extract_stage(5,4).lost_bauxites

count_bauxi = 0
count_syutu = 0
max_bauxi = 0
min_bauxi = 20000

slots.each_with_index do |start_slots, i|
  if start_slots.to_s.include?("15.5cm三連装副砲")
    count_syutu += 1
    puts "#{count_syutu}回目"

    start_slots.each_with_index do |kanmusu_slot, j|
      count_bauxi += bauxi[i][j]
      if kanmusu_slot.to_s.include?("15.5cm三連装副砲")
        max_bauxi = [max_bauxi, bauxi[i][j]].max
        min_bauxi = [min_bauxi, bauxi[i][j]].min
      end
      puts "名前：#{names[i][j]}、装備：#{kanmusu_slot.to_s}、ボーキ消費：#{bauxi[i][j]}"
    end
    puts
  end
end
puts "出撃回数：#{count_syutu}、平均ボーキ：#{count_bauxi/count_syutu}"
puts max_bauxi
puts min_bauxi
# p stage.length
# p stage.extract_stage(5, 4).length # 5-4に出撃した回数
# p stage.extract_stage(5, 4).bauxites # 5-4のボーキ数(Array)
# stage_5_4 = stage.extract_stage(5, 4).extract_route([1, 8, 17, 18, 19])
# p stage_5_4.bauxites
# p stage_5_4.entry_files[0].hantei
# p stage_5_4.hantei.length
# p stage.extract_stage(1,4).lost_bauxites
# p stage.extract_stage(1,4).slots

# stage_5_4.entry_files[0].file.each {|file| p file[:next] }
#p stage_5_4.length # 5-4かつ、ルートを指定した出撃数


# ## 5-4の艦娘たちの名前
# status = StartStatus::parse(stage_5_4.datas)

# status.start.each do |stat|
#   p status.names[stat]
# end

# b_5_4 = stage_5_4.file[stage_5_4.start[0]]

# p Hantei::syouri(b_5_4[0][:battle])
