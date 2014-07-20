# -*- coding: utf-8 -*-
## モデルから自由に変更可能クラス

module Kancolle
  class EntryFile < Kancolle::Model

    public
    ##################################################################
    # インスタンスメソッド                                           #
    ##################################################################
    # マップ情報 return [マップ番号、ステージ番号]
    def map
      open(@start) do |s|
        start_json = JSON::parse(s.read)
        return [start_json["api_data"]["api_maparea_id"], start_json["api_data"]["api_mapinfo_no"]]
      end
    end
    # ボーキサイト
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
    # ルート
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
    # 名前
    def names
      names        = Array.new(6).map{nil}
      id_names     = Array.new(6).map{nil}
      sortno_names = Array.new(6).map{nil}
      port = nil
      open(@port) {|p| port = JSON::parse(p.read)}
      start2 = nil
      open(@start2) {|s| start2 = JSON::parse(s.read)}
      id_names = port["api_data"]["api_deck_port"][0]["api_ship"]
      port["api_data"]["api_ship"].each do |kanmusu|
        id_names.each_with_index do |id_name, i|
          sortno_names[i] = kanmusu["api_sortno"] if id_name == kanmusu["api_id"]
        end
      end
      start2["api_data"]["api_mst_ship"].each do |kanmusu|
        sortno_names.each_with_index do |sortno_name, i|
          names[i] = kanmusu["api_name"] if sortno_name == kanmusu["api_sortno"]
        end
      end
      return names
    end
    # 勝利判定現在はB勝利のみ
    def hantei
      hantei = Array.new
      @file.each_with_index do |file, i|
        if file[:battle].nil?
          hantei[i] = nil
        else
          hantei[i] = Hantei::syouri(file[:battle])
        end
      end
      return hantei
    end
    ##################################################################
    # end インスタンスメソッド                                       #
    ##################################################################
  end
end








