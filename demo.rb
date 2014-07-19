# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(__dir__ + "/lib")

require "rubygems"
require "kancolle"

include Kancolle

## 5-4のファイルを出力
stage = FindEntryFile::parse_for_dir(ARGV[0])

p stage.length
p stage.extract_stage(5, 4).length # 5-4に出撃した回数
p stage.extract_stage(5, 4).bauxites # 5-4のボーキ数(Array)
stage_5_4 = stage.extract_stage(5, 4).extract_route([1, 8, 17, 18, 19])
p stage_5_4.bauxites
#p stage_5_4.length # 5-4かつ、ルートを指定した出撃数


# ## 5-4の艦娘たちの名前
# status = StartStatus::parse(stage_5_4.datas)

# status.start.each do |stat|
#   p status.names[stat]
# end

# b_5_4 = stage_5_4.file[stage_5_4.start[0]]

# p Hantei::syouri(b_5_4[0][:battle])
