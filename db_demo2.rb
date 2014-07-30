# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(__dir__ + "/lib")

require "rubygems"
require "kancolle"

include Kancolle
start_time = Time.now

DbConnection::insert

puts "処理時間：#{Time.now-start_time}s"
