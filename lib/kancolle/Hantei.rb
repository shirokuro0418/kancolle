# -*- coding: utf-8 -*-
## BattleファイルからB勝利か負けか判定

module Kancolle
  class Hantei
    def self.syouri(file)
      f_nowhp, f_nokorihp, e_nowhp, e_nokorihp = Hantei::battle_damage(file)
      count_enemy      = e_nowhp.select{|hp| hp > 0}.length
      count_enemy_lost = e_nokorihp.select{|hp| hp > 0}.length

      # S勝利の判定
      if e_nokorihp == [0, 0, 0, 0, 0 ,0]
        if f_nowhp == f_nokorihp
          return "完全勝利"
        else
          return "S勝利"
        end
      end
      # A勝利判定
      case count_enemy
      when 1                    # なし
      when 2
        return "A勝利" if count_enemy_lost == 1
      when 3
        return "A勝利" if 2 == count_enemy_lost
      when 4
        return "A勝利" if 2 <= count_enemy_lost && count_enemy_lost <= 3
      when 5
        return "A勝利" if 3 <= count_enemy_lost && count_enemy_lost <= 4
      when 6
        return "A勝利" if 3 <= count_enemy_lost && count_enemy_lost <= 5
      end

      # B勝利判定
      f_rate = 100000 - 100000 * f_nokorihp.inject{|sum, n| sum += n} / f_nowhp.inject{|sum, n| sum += n}
      e_rate = 100000 - 100000 * e_nokorihp.inject{|sum, n| sum += n} / e_nowhp.inject{|sum, n| sum += n}

      if f_rate != 0 && (100 * e_rate / f_rate) >= 250 ||
          f_rate == 0 && e_rate != 0
        return "B勝利"
      elsif e_nokorihp[0] == 0
        return "B勝利"          # 敵旗艦を倒す
      else
        return "負け"
      end
    end
    def self.mvp(file)
      # 保留
    end

    private

    def self.damage(nowhp, damage)
      if nowhp - damage < 0
        nowhp
      else
        damage
      end
    end
    def self.battle_damage(file)
      open(file) do |f|
        json = JSON::parse(f.read)
        data = json["api_data"]

        ## 現在のHP
        f_nowhp = json["api_data"]["api_nowhps"][1..6].map{|v| if v == -1 then 0 else v end}
        e_nowhp = json["api_data"]["api_nowhps"][7..12].map{|v| if v == -1 then 0 else v end}

        tmp_f_nowhp = f_nowhp.clone
        tmp_e_nowhp = e_nowhp.clone
        ## 航空戦
        if json["api_data"]["api_stage_flag"][2] == 1
          data["api_kouku"]["api_stage3"]["api_fdam"].each_with_index do |dam, i|
            tmp_f_nowhp[i-1] -= Hantei::damage(tmp_f_nowhp[i-1], dam.to_i) if dam != -1
          end
          data["api_kouku"]["api_stage3"]["api_edam"].each_with_index do |dam, i|
            tmp_e_nowhp[i-1] -= Hantei::damage(tmp_e_nowhp[i-1], dam.to_i) if dam != -1
          end
        end

        ## オープニング雷撃
        if data["api_opening_flag"] == 1
          data["api_opening_atack"]["api_fdam"].each_with_index do |dam, i|
            tmp_f_nowhp[i-1] -= Hantei::damage(tmp_f_nowhp[i-1], dam.to_i) if dam != -1
          end
          data["api_opening_atack"]["api_edam"].each_with_index do |dam, i|
            tmp_e_nowhp[i-1] -= Hantei::damage(tmp_e_nowhp[i-1], dam.to_i) if dam != -1
          end
        end

        ## 砲撃
        if data["api_hourai_flag"][0] == 1
          data["api_hougeki1"]["api_at_list"].each_with_index do |list, i|
            if 1 <= list && list <= 6
              data["api_hougeki1"]["api_damage"][i].each_with_index do |dam, j|
                e_kan = data["api_hougeki1"]["api_df_list"][i][j]-7
                tmp_e_nowhp[e_kan] -= Hantei::damage(tmp_e_nowhp[e_kan], dam.to_i) if dam != -1
              end
            elsif 7 <= list && list <= 12
              data["api_hougeki1"]["api_damage"][i].each_with_index do |dam, j|
                f_kan = data["api_hougeki1"]["api_df_list"][i][j]-1
                tmp_f_nowhp[f_kan] -= Hantei::damage(tmp_f_nowhp[f_kan], dam.to_i) if dam != -1
              end
            end
          end
        end
        if data["api_hourai_flag"][1] == 1
          data["api_hougeki2"]["api_at_list"].each_with_index do |list, i|
            if 1 <= list && list <= 6
              data["api_hougeki2"]["api_damage"][i].each_with_index do |dam, j|
                e_kan = data["api_hougeki2"]["api_df_list"][i][j]-7
                tmp_e_nowhp[e_kan] -= Hantei::damage(tmp_e_nowhp[e_kan], dam.to_i) if dam != -1
              end
            elsif 7 <= list && list <= 12
              data["api_hougeki2"]["api_damage"][i].each_with_index do |dam, j|
                f_kan = data["api_hougeki2"]["api_df_list"][i][j]-1
                tmp_f_nowhp[f_kan] -= Hantei::damage(tmp_f_nowhp[f_kan], dam.to_i) if dam != -1
              end
            end
          end
        end

        ## エンド雷撃
        if data["api_hourai_flag"][3] == 1
          data["api_raigeki"]["api_fdam"].each_with_index do |dam, i|
            tmp_f_nowhp[i-1] -= Hantei::damage(tmp_f_nowhp[i-1], dam.to_i) if dam != -1
          end
          data["api_raigeki"]["api_edam"].each_with_index do |dam, i|
            tmp_e_nowhp[i-1] -= Hantei::damage(tmp_e_nowhp[i-1], dam.to_i) if dam != -1
          end
        end

        return [ f_nowhp, tmp_f_nowhp, e_nowhp, tmp_e_nowhp ]
      end
    end
  end
end
