# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(__dir__ + "/lib")

require "rubygems"
require "kancolle"

include Kancolle

s = FindEntryFile::parse_for_dir

eval("puts s.#{ARGV[0]}")

