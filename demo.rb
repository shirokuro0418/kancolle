# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(__dir__ + "/lib")

require "rubygems"
require "kancolle"
require "json"

include Kancolle

## 5-4のファイルを出力
stage = FindEntryFile.new(ARGV[0])

p stage.extract(5, 4)
