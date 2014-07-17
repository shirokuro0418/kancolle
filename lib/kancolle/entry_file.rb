# -*- coding: utf-8 -*-
## モデルから自由に変更可能クラス

module Kancolle
  class EntryFile < Kancolle::Model
    ## マップ情報 return [マップ番号、ステージ番号]
    def map
      open(@start) do |s|
        start_json = JSON::parse(s.read)
        return [start_json["api_data"]["api_maparea_id"], start_json["api_data"]["api_mapinfo_no"]]
      end
    end

    ## ボーキサイト
    def bauxite
      count_lost = 0
      @file.each do |file|
        next if file[:battle].nil?
        open(file[:battle]) do |b|
          bat_json = JSON::parse(b.read)
          if bat_json['api_data']['api_stage_flag'][0] == 1
            count_lost     += bat_json['api_data']['api_kouku']["api_stage1"]["api_f_lostcount"]
          end
          if bat_json['api_data']['api_stage_flag'][2] == 1
            count_lost     += bat_json['api_data']['api_kouku']["api_stage2"]["api_f_lostcount"]
          end
        end
      end
      return count_lost * 5
    end

    ## ルート
    def route
      route = Array.new
      open(@start) do |s|
        start = JSON::parse(s.read)
        route.push(start["api_data"]["api_no"])
      end
      tmp_file = @file
      tmp_file.shift
      tmp_file.each do |file|
        open(file[:next]) do |n|
          tugi = JSON::parse(n.read)
          route.push(tugi["api_data"]["api_no"])
        end
      end
      return route
    end
  end
end
