# -*- coding: utf-8 -*-
module Kancolle
  class Hantei
    def self.read(json)
      map = [ json[:start]["api_data"]["api_maparea_id"], json[:start]["api_data"]["api_mapinfo_no"] ]

      if map[0] == 27 && [3,4,5].include?(map[1])
        return nil
      else
        hantei = Array.new
        json[:file].each_with_index do |file, i|
          if file[:battle_result].nil?
            hantei[i] = nil
          else
            hantei[i] = file[:battle_result]["api_data"]["api_win_rank"]
          end
        end
        return hantei
      end
    end
  end
end
