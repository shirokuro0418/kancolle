# -*- coding: utf-8 -*-
module Kancolle
  class BattleForms
    def self.read(json)
      map = [ json[:start]["api_data"]["api_maparea_id"], json[:start]["api_data"]["api_mapinfo_no"] ]
      if map[0] == 27 && [3,4,5].include?(map[1])
        return nil
      else
        forms = Array.new
        json[:file].each do |file_json|
          unless file_json[:battle].nil?
            case file_json[:battle]["api_data"]["api_formation"][2]
            when 1
              kousen = "同行戦"
            when 2
              kousen = "反航戦"
            when 3
              kousen = "T字有利"
            when 4
              kousen = "T字不利"
            else
              kousen = "謎"
            end

            forms.push(kousen)
          else
            forms.push(nil)
          end
        end
        forms
      end
    end
  end
end
