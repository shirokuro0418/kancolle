# -*- coding: utf-8 -*-
module Kancolle
  class Seiku
    def self.read(json)
      map = [ json[:start]["api_data"]["api_maparea_id"], json[:start]["api_data"]["api_mapinfo_no"] ]
      if map[0] == 27 && [3,4,5].include?(map[1])
        return nil
      else
        seiku = Array.new
        json[:file].each do |file_json|
          unless file_json[:battle].nil?
            unless file_json[:battle]["api_data"]["api_stage_flag"][0] == 0
              case file_json[:battle]["api_data"]["api_kouku"]["api_stage1"]["api_disp_seiku"]
              when 0
                kousen = "互角"
              when 1
                kousen = "制空権確保"
              when 2
                kousen = "航空優勢"
              when 3
                kousen = "航空劣勢"
              when 4
                kousen = "制空権消失"
              else
                kousen = "謎"
              end

              seiku.push(kousen)
            else
              seiku.push("謎の場所")
            end
          else
            seiku.push(nil)
          end
        end
        return seiku
      end
    end
  end
end
