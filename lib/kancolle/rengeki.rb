# -*- coding: utf-8 -*-

module Kancolle
  class Rengeki
    def self.read(json)
      map = [ json[:start]["api_data"]["api_maparea_id"], json[:start]["api_data"]["api_mapinfo_no"] ]
      if map[0] == 27 && [3,4,5].include?(map[1])
        return nil
      else
        hougeki = Array.new(6).map{0}
        json[:file].each do |file|
          unless file[:battle].nil?
            hougeki1 = Array.new(6).map{0}
            hougeki2 = Array.new(6).map{0}

            hougeki1 = hougeki(file[:battle]["api_data"]["api_hougeki1"]) if file[:battle]["api_data"]["api_hourai_flag"][0] == 1
            hougeki2 = hougeki(file[:battle]["api_data"]["api_hougeki2"]) if file[:battle]["api_data"]["api_hourai_flag"][1] == 1

            hougeki.map!.with_index{|r,i| r += hougeki1[i]+hougeki2[i]}
          end
        end
        return hougeki
      end
    end

    private

    # 砲撃の連撃を取得
    def self.hougeki(hougeki)
      kanmusus = Array.new(6).map{0}
      # 攻撃順
      hougeki["api_at_list"].each_with_index do |l,i|
        if 1 <= l && l <= 6
          # 連撃判定
          kanmusus[l-1] += 1 if hougeki["api_si_list"][i].length == 2
        end
      end
      kanmusus
    end
  end
end
