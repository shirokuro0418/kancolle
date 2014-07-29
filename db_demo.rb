# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(__dir__ + "/lib")

require "rubygems"
require "kancolle"

include Kancolle
start_time = Time.now


# lvや獲得合計経験値を返す
def stat(id, ids, entry_files)
  stage_s_num = nil
  stage_e_num = nil
  catch(:s_name) do
    ids.each_with_index do |kantai_ids, ii|
      kantai_ids.each_with_index do |kantai_id, jj|
        if kantai_id == id
          stage_s_num = [ ii, jj ]
          throw :s_name
        end
      end
    end
  end
  catch(:e_name) do
    ids.reverse_each.with_index do |kantai_ids, ii|
      kantai_ids.each_with_index do |kantai_id, jj|
        if kantai_id == id
          stage_e_num = [ entry_files.length-1-ii, jj ]
          throw :e_name
        end
      end
    end
  end
  s_lv  = entry_files.entry_files[stage_s_num[0]].lvs[stage_s_num[1]]
  e_lv  = entry_files.entry_files[stage_e_num[0]].lvs[stage_e_num[1]]
  s_exp = entry_files.entry_files[stage_s_num[0]].now_exps[stage_s_num[1]]
  if (e_exp = entry_files.entry_files[stage_e_num[0]].now_exps_end[stage_e_num[1]]).nil?
    return nil                  # 解体または轟沈
  end
  [ s_lv, e_lv-s_lv, e_lv, e_exp-s_exp ]
end

MARRIAGES = {
  1822  => false,        # 阿武隈改
  460   => false,        # 加賀改
  2162  => false,        # 大和改
  12110 => false,        # 大鳳改
  1     => false,        # 電改
  2189  => false,        # 金剛改二
  38    => false,        # 時雨改二
  55    => false,        # 北上改二
  341   => false,        # 摩耶改
  905   => false         # 夕張改
}
MANTH = 7
RANKING = 5

str_arr = Array.new

stage = DbEntryFiles.new
stage = stage.between_days(man=Date.new(2014,MANTH), Date.new(2014,MANTH+1)-1)

# 使った艦娘ワースト10
# count_kanmusu key   : id
#               value : [ 艦娘の名前, 出撃で使った回数, Sレベル, 上がり, Eレベル,
#                         合計獲得経験値 ]
count_kanmusus = Hash.new
ids   = stage.ids
names = stage.names
lvs   = stage.lvs
ids.each_with_index do |kantai_ids, i|
  kantai_ids.each_with_index do |id, j|
    # lv10未満は含まない
    next if id == -1 || lvs[i][j] < 10
    if count_kanmusus[id].nil?
      count_kanmusus[id] = [names[i][j], 1]
    else
      count_kanmusus[id][1] += 1
    end
  end
end
# その他のステータス
count_kanmusus.each do |id, value|
  if (stat = stat(id, ids, stage)).nil?
    count_kanmusus.delete(id)
  else
    count_kanmusus[id] = value + stat
  end
end

str_arr.push "#{man.month}月の集計"
##################################################################
# レベルでソート
##################################################################
str_arr.push "出撃回数ランク"
str_arr.push "-----------------------------------------------------------------"
str_arr.push "|順位\t|名前\t\t|出撃\t|レベル\t\t|合計獲得経験値\t|"
str_arr.push "-----------------------------------------------------------------"

mar_flg = MARRIAGES
count_kanmusus.sort{|(ak,av),(bk,bv)|bv[1]<=>av[1]}.each.with_index(1) do |kanmusu, i|
  tmp_kanmusu = kanmusu[1].clone
  if i <= RANKING
    str_arr.push "|%3d位\t|%10s\t|%4d\t| %3d %+3d %3d\t|%10d\t|" % tmp_kanmusu.unshift(i)
    mar_flg[kanmusu[0]] = true if mar_flg.keys.include?(kanmusu[0])
  elsif mar_flg[1822] # mar_flg.values.all?{|val|val}
    break
  else
    ## ケッコン艦を表示
    if i == RANKING+1
      str_arr.push "|  ・   |       ・      |  ・   |       ・      |       ・      |"
    end
    if kanmusu[0] == 1822 # mar_flg.keys.include?(kanmusu[0])
      str_arr.push "|%3d位\t|%10s\t|%4d\t| %3d %+3d %3d\t|%10d\t|" % tmp_kanmusu.unshift(i)
      break
      # mar_flg[kanmusu[0]] = true
    end
  end
end
str_arr.push "-----------------------------------------------------------------"

##################################################################
# 経験値でソート
##################################################################
str_arr.push "\n"
str_arr.push "合計経験値ランク"
str_arr.push "-----------------------------------------------------------------"
str_arr.push "|順位\t|名前\t\t|出撃\t|レベル\t\t|合計獲得経験値\t|"
str_arr.push "-----------------------------------------------------------------"

mar_flg = MARRIAGES
count_kanmusus.sort{|(ak,av),(bk,bv)|bv[5]<=>av[5]}.each.with_index(1) do |kanmusu, i|
  tmp_kanmusu = kanmusu[1].clone
  if i <= RANKING
    str_arr.push "|%3d位\t|%10s\t|%4d\t|%6d %+3d %3d\t|%10d\t|" % tmp_kanmusu.unshift(i)
    mar_flg[kanmusu[0]] = true if mar_flg.keys.include?(kanmusu[0])
  elsif mar_flg[1822] # mar_flg.values.all?{|val|val}
    break
  else
    ## ケッコン艦を表示
    if i == RANKING+1
      str_arr.push "|  ・   |       ・      |  ・   |       ・      |       ・      |"
    end
    if mar_flg.keys.include?(kanmusu[0])
      str_arr.push "|%3d位\t|%10s\t|%4d\t|%6d %+3d %3d\t|%10d\t|" % tmp_kanmusu.unshift(i)
      break
      # mar_flg[kanmusu[0]] = true
    end
  end
end
str_arr.push "-----------------------------------------------------------------"


str_arr.each do |str|
  puts str
end

puts "処理時間：#{Time.now-start_time}s"
