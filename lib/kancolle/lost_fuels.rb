# -*- coding: utf-8 -*-
module Kancolle
  class LostFuels
    def self.read(json)
      ids = json[:port]["api_data"]["api_deck_port"][0]["api_ship"]
      lvs = ids.map{|id| if id.nil? then nil else self.port_ship(id, "api_lv", json[:port]) end }

      # 出撃した時の燃料の消費
      # lv10未満は飛ばす
      now_syutugeki_fuel = Array.new
      now_nyukyo_fuel    = Array.new
      ids.each_with_index do |id, i|
        if id == -1 || lvs[i] < 10
          now_syutugeki_fuel[i] = 0
          now_nyukyo_fuel[i]    = 0
        else
          json[:port]["api_data"]["api_ship"].each do |kanmusu|
            if kanmusu["api_id"] == id
              now_syutugeki_fuel[i] = kanmusu["api_fuel"]
              now_nyukyo_fuel[i]    = kanmusu["api_ndock_item"][0]
              break
            end
          end
        end
      end
      end_syutugeki_fuel = Array.new
      end_nyukyo_fuel    = Array.new
      ids.each_with_index do |id, i|
        if id == -1 || lvs[i] < 10
          end_syutugeki_fuel[i] = 0
          end_nyukyo_fuel[i] = 0
        else
          json[:end_port]["api_data"]["api_ship"].each do |kanmusu|
            if kanmusu["api_id"] == id
              end_syutugeki_fuel[i] = kanmusu["api_fuel"]
              end_nyukyo_fuel[i]    = kanmusu["api_ndock_item"][0]
              break
            end
          end
        end
      end
      Array.new(6).map.with_index do |n, i|
        lost_fuels = end_nyukyo_fuel[i] - now_nyukyo_fuel[i]
        # ケッコン艦は15%off
        if lvs[i] > 99
          lost_fuels += ((now_syutugeki_fuel[i] - end_syutugeki_fuel[i]) * 0.85).to_i
        else
          lost_fuels += now_syutugeki_fuel[i] - end_syutugeki_fuel[i]
        end
        lost_fuels
      end
    end

    private
    # portファイルのspi_shipからデータを取得
    def self.port_ship(id, key, port_json)
      port_ship = port_json["api_data"]["api_ship"]
      if id == -1
        return nil
      elsif !Kanmusu::port_kanmusu_iti(id).nil?
        # 念のため一致してるかチェック
        if port_ship[Kanmusu::port_kanmusu_iti(id)].nil? ||
            id != port_ship[Kanmusu::port_kanmusu_iti(id)]["api_id"]
          # １つずつ調べる
          port_ship.reverse_each.with_index do |kanmusu,i|
            if kanmusu["api_id"] == id
              Kanmusu::port_kanmusu_iti_push(id, port_ship.length-i-1)
              return kanmusu[key]
            end
          end
        else
          return port_ship[Kanmusu::port_kanmusu_iti(id)][key]
        end
      else
        # １つずつ調べる
        port_ship.each_with_index do |kanmusu, i|
          if kanmusu["api_id"] == id
            Kanmusu::port_kanmusu_iti_push(id, i)
            return kanmusu[key]
          end
        end
      end
      return nil
    end
  end
end
