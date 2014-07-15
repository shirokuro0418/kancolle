# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(__dir__ + "/lib")

require "rubygems"
require "kancolle"

include Kancolle

## 5-4のファイルを出力
stage = FindEntryFile.new(ARGV[0])

stage_5_4 = stage.extract(5, 4)

# 5-4にいったスタートファイル
p stage_5_4.start
# 5-4に出撃した際、止まったマスの回数
stage_5_4.start.each do |start|
  p stage_5_4.file[start].length
end
