# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(__dir__ + "/lib")

require "rubygems"
require "kancolle"

include Kancolle
start_time = Time.now

DbConnection::insert_newrest

if ARGV[0].nil?
  day = Date::today
else
  day = Date::today - ARGV[0].to_i
end

print "#{day.month}月#{day.day}日集計\n\n"

stage = DbConnection::between_days(day, day+1)

port = nil
e_port = nil
Kanmusu::dir.each do |dir|
  next if dir != "/Users/shirokuro11/Documents/koukai_nisshi/data/json/json" &&
    Date.new(2014, dir[-5,2].to_i, dir[-2,2].to_i) < day
  Dir.open(dir) do |d|
    d.each do |file|
      if file =~ /PORT.json$/ && Date::parse(file.slice(/^.*?_/).sub(/_/,'')) == day
        port = d.path + "/" + file
        break
      end
    end
  end
end
Kanmusu::dir.reverse_each do |dir|
  Dir.open(dir) do |d|
    d.reverse_each do |file|
      if file =~ /PORT.json$/ && Date::parse(file.slice(/^.*?_/).sub(/_/,'')) == day
        e_port = d.path + "/" + file
        break
      end
    end
  end
end

syouhi = Array.new
syouhi.push "出撃回数：#{stage.length}"
syouhi.push "出撃での消費"
syouhi.push "燃料：#{stage.lost_fuels.flatten.inject(:+)}"
syouhi.push "弾薬：#{stage.lost_bulls.flatten.inject(:+)}"
syouhi.push "ボキ：#{stage.lost_bauxites.flatten.inject(:+)}"

syunyu = Array.new
syunyu.push "回収"
syunyu.push "燃料：#{stage.got_fuels.flatten.inject(:+)}"
syunyu.push "弾薬：#{stage.got_bulls.flatten.inject(:+)}"
syunyu.push "鋼材：#{stage.got_steels.flatten.inject(:+)}"
syunyu.push "ボキ：#{stage.got_bauxisites.flatten.inject(:+)}"

count_stage = Hash.new
for i in 1..5
  for j in 1..5
    count_stage["#{i}-#{j}"] = stage.extract_stage(i,j).length
  end
end
i = 0
count_stage.sort{|(ak,av),(bk,bv)|ak<=>bk}.each do |s|
  if ["1-1", "2-2", "2-3", "3-2", "4-2", "5-4", "5-5"].include? s[0]
    puts "#{"%3s"%s[0]} #{"%3d"%s[1]} \t #{syouhi[i]} \t #{syunyu[i]}"
    i += 1
  end
end
puts ""

resource = Array.new(4)
open(port) do |p|
  json = JSON::parse(p.read)
  json["api_data"]["api_material"].each_with_index do |m, i|
    resource[i] = m["api_value"]
  end
end
e_resource = Array.new(4)
open(e_port) do |p|
  json = JSON::parse(p.read)
  json["api_data"]["api_material"].each_with_index do |m, i|
    e_resource[i] = m["api_value"]
  end
end

puts "資源"
puts "燃料　：#{"%6d"%resource[0]} #{"%+5d"%(e_resource[0]-resource[0])} #{"%6d"%e_resource[0]}"
puts "弾薬　：#{"%6d"%resource[1]} #{"%+5d"%(e_resource[1]-resource[1])} #{"%6d"%e_resource[1]}"
puts "鋼材　：#{"%6d"%resource[2]} #{"%+5d"%(e_resource[2]-resource[2])} #{"%6d"%e_resource[2]}"
puts "ボキ　：#{"%6d"%resource[3]} #{"%+5d"%(e_resource[3]-resource[3])} #{"%6d"%e_resource[3]}"
puts "バケツ：#{"%6d"%resource[5]} #{"%+5d"%(e_resource[5]-resource[5])} #{"%6d"%e_resource[5]}"

puts ""

puts "処理時間：#{Time.now-start_time}s"
