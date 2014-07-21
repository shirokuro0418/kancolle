# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(__dir__ + "/lib")

require "rubygems"
require "kancolle"

include Kancolle

stage = FindEntryFile::parse_for_dir(ARGV[0])
p stage.day(Date.parse("2014-7-21")).lost_bulls.flatten.inject(:+)
