# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(__dir__ + "/lib")

require "rubygems"
require "kancolle"

include Kancolle

## 5-4のファイルを出力
stage = FindEntryFile.new(ARGV[0])

stage_5_4 = stage.extract(5, 4)

p stage_5_4.start[0]
p stage_5_4.file[stage_5_4.start[0]].length
