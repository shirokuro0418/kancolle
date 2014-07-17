# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(__dir__ + "/lib")

require "rubygems"
require "kancolle"

include Kancolle

## 5-4のファイルを出力
stage = FindEntryFile::parse_fro_dir(ARGV[0])

stage_5_4 = stage.extract(5, 4)

# 5-4にいったスタートファイル
p stage_5_4.start
# 5-4に出撃した際、止まったマスの回数
stage_5_4.start.each do |start|
  p stage_5_4.file[start].length
end


## 5-4の艦娘たちの名前
status = StartStatus::parse(stage_5_4.datas)

status.start.each do |stat|
  p status.names[stat]
end

b_5_4 = stage_5_4.file[stage_5_4.start[0]]

p Hantei::syouri(b_5_4[0][:battle])
