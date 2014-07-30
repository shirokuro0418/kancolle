# -*- coding: utf-8 -*-
## モデルから自由に変更可能クラス

module Kancolle
  class EntryFile < Kancolle::Model
    # @start startファイルの配列
    # @file @start[x]をkeyとした１出撃のファイル群
    # @file[@start[x]][x][ :ship2           ]
    #                    [ :battle          ]
    #                    [ :next            ]
    #                    [ :battle_result   ]
    # @start2          @start[x]をkeyとしたSTART2.jsonのファイルパス
    # @slotitem_member 〃                  SLOTITEM_BEMBER.jsonのファイルパス
    attr_reader :start, :file, :start2, :slotitem_member, :port, :end_port, :end_slotitem_member

    def initialize(datas = {})
      super(datas)

      @ids           = Array.new
      @map           = Array.new # マップ情報 return [マップ番号、ステージ番号]
      @lvs           = Array.new
      # 失った資源
      @lost_fuels    = Array.new
      @lost_bulls    = Array.new
      @lost_bauxites = Array.new

      @route         = Array.new
      @names         = Array.new
      # @names_low     = Array.new
      @slots         = Array.new
      @hantei        = Array.new # 勝利判定
      @rengeki       = Array.new
      @battle_forms  = Array.new # 交戦形態(同行戦、反航戦、etc)
      @seiku         = Array.new
      @exps          = Array.new
      @now_exps      = Array.new
      @now_exps_end  = Array.new
      # 今はバシー、オリョクル、キスのみ。
      @got_fuel      = 0
      @got_bull      = 0
      @got_steel     = 0
      @got_bauxisite = 0
    end

    ##################################################################
    # インスタンスメソッド                                           #
    ##################################################################
    public
    def ids
      read_all
      @ids
    end
    def map
      read_all
      @map
    end
    def lvs
      read_all
      @lvs
    end
    def lost_fuels
      read_all
      @lost_fuels
    end
    def lost_bulls
      read_all
      @lost_bulls
    end
    def lost_bauxites
      read_all
      @lost_bauxites
    end
    def route
      read_all
      @route
    end
    def names
      read_all
      @names
    end
    def slots
      read_all
      @slots
    end
    def hantei
      read_all
      @hantei
    end
    def rengeki
      read_all
      @rengeki
    end
    def battle_forms
      read_all
      @battle_forms
    end
    def seiku
      read_all
      @seiku
    end
    def exps
      read_all
      @exps
    end
    def now_exps
      read_all
      @now_exps
    end
    def now_exps_end
      read_all
      @now_exps_end
    end
    def got_fuel
      read_all
      @got_fuel
    end
    def got_bull
      read_all
      @got_bull
    end
    def got_steel
      read_all
      @got_steel
    end
    def got_bauxisite
      read_all
      @got_bauxisite
    end

    def to_db
      dont_need_var = [ :@file, :@start, :@start2, :@slotitem_member,
                        :@port, :@end_port, :@end_slotitem_member
                      ]
      h = Hash.new
      year, man, day, other = @start.sub(/^.*\//, '').sub(/\..*$/, '').sub!(/_/, '-').split('-')
      day = Time.local(year, man, day, other[0..1], other[2..3], other[4..5])
      h[:date] = day
      self.instance_variables.each do |var|
        unless dont_need_var.include? var
          h[var.to_s.sub(/@/, '')] = (eval var.to_s.sub(/@/, '').to_s)
        end
      end
      h
    end

    ##################################################################
    # private                                                        #
    ##################################################################
    private
    # 初期化
    def read_all
      if @ids.empty?
        start2_json               = read_json(@start2)
        port_json                 = read_json(@port)
        end_port_json             = read_json(@end_port)
        start_json                = read_json(@start)
        slotitem_member_json      = read_json(@slotitem_member)
        end_slotitem_member_json  = read_json(@end_slotitem_member)
        file_json                 = Array.new(@file.length)
        # file_jsonの読み込み
        @file.each_with_index do |map_info, i|
          map_info_json = Hash.new
          map_info.each do |map_info_key, map_info_value|
            if map_info_value.nil?
              map_info_json[map_info_key] = nil
            else
              open(map_info_value){|j| map_info_json[map_info_key] = JSON::parse(j.read)}
            end
          end
          file_json[i] = map_info_json
        end

        @ids = port_json["api_data"]["api_deck_port"][0]["api_ship"]
        @map = [start_json["api_data"]["api_maparea_id"], start_json["api_data"]["api_mapinfo_no"]]
        @lvs = read_lvs(port_json)
        @lost_fuels    = read_lost_resources(port_json, end_port_json, "api_fuel")
        @lost_bulls    = read_lost_resources(port_json, end_port_json, "api_bull")
        @lost_bauxites = read_lost_bauxites(port_json, end_port_json)

        tmp = file_json.clone
        @route         = read_route(start_json, file_json)
        @names         = read_names(port_json, start2_json)
        # @names_low     = read_names_low
        @slots         = Array.new(6).map{Array.new(5)}
        # slotsの読み込み
        ids.map{|id| port_ship(id, "api_slot", port_json)}.each_with_index do |kanmusu_slot, i|
          if kanmusu_slot.nil?
            @slots[i] = nil
          else
            kanmusu_slot.each_with_index do |slot_id, j|
              @slots[i][j] = start2_slotitem(slot_id, slotitem_member_json, start2_json, end_slotitem_member_json)
            end
          end
        end
        @hantei = file_json.map do |jsons|
          if jsons[:battle_result].nil?
            nil
          else
            jsons[:battle_result]["api_data"]["api_win_rank"]
          end
        end

        hougeki1          = read_hougeki1(file_json)
        hougeki2          = read_hougeki2(file_json)
        @rengeki          = read_rengeki(hougeki1, hougeki2)
        @battle_forms     = read_battle_forms(file_json)
        @seiku            = read_seiku(file_json)
        @exps             = read_exps(port_json, end_port_json)
        @now_exps         = read_now_exps(:start, port_json, end_port_json)
        @now_exps_end     = read_now_exps(:end, port_json, end_port_json)

        # バシー、オリョクル、キスの獲得資源　他のステージは全部0になる
        case @map
        when [2,2]
          @route.each_with_index do |route, i|
            if [2,3,8].include?(route)
              if i == 0
                @got_bauxisite += start_json["api_data"]["api_itemget"]["api_getcount"]
              else
                @got_bauxisite += file_json[i][:next]["api_data"]["api_itemget"]["api_getcount"]
              end
            end
          end
        when [2,3]
          @route.each_with_index do |route, i|
            if [2,6,7].include?(route)
              if i == 0
                @got_fuel += start_json["api_data"]["api_itemget"]["api_getcount"]
              else
                @got_fuel += file_json[i][:next]["api_data"]["api_itemget"]["api_getcount"]
              end
            end
          end
          @route.each_with_index do |route, i|
            if [4,8].include?(route)
              if i == 0
                @got_bull += start_json["api_data"]["api_itemget"]["api_getcount"]
              else
                @got_bull += file_json[i][:next]["api_data"]["api_itemget"]["api_getcount"]
              end
            end
          end
        when [3,2]
          @route.each_with_index do |route, i|
            if [5].include?(route)
              if i == 0
                @got_steel += start_json["api_data"]["api_itemget"]["api_getcount"]
              else
                @got_steel += file_json[i][:next]["api_data"]["api_itemget"]["api_getcount"]
              end
            end
          end
        else
        end
      end
    end

    def read_json(file)
      open(file) do |f|
        return JSON::parse(f.read)
      end
    end
    def read_lvs(port_json)
      @ids.map do |id|
        if id.nil?
          nil
        else
          port_ship(id, "api_lv", port_json)
        end
      end
    end
    def read_lost_resources(port_json, end_port_json, key_name)
      # lv10未満は飛ばす
      now_resources = lost_resources(port_json, key_name)
      max_resources = lost_resources(end_port_json, key_name)
      # ケッコン艦は15%off
      @lvs.each_with_index do |lv, i|
        next if lv.nil?
        now_resources[i] = (max_resources[i] - ((max_resources[i] - now_resources[i]) * 0.85).to_i) if lv > 99
      end
      max_resources.map.with_index{|m_fuel, i| m_fuel - now_resources[i]}
    end
    def read_lost_bauxites(port_json, end_port_json)
      # lv10未満は飛ばす
      max_onslot = lost_resources(port_json, "api_onslot")
      now_onslot = lost_resources(end_port_json,"api_onslot")

      max_onslot.map.with_index{|slot, i| (slot - now_onslot[i]) * 5 unless slot.nil?}
    end
    def read_route(start_json, file_json)
      route = Array.new
      route.push(start_json["api_data"]["api_no"])
      tmp_file = file_json.clone
      tmp_file.shift
      tmp_file.each do |file_json|
        route.push(file_json[:next]["api_data"]["api_no"])
      end
      route
    end
    def read_names(port_json, start2_json)
      names = Array.new(6).map{nil}

      ids.each_with_index do |id, i|
        if id == -1
          next
        elsif !(names[i] = Kanmusu::kanmusu_names[id]).nil?
        else
          sortno = nil
          port_json["api_data"]["api_ship"].reverse_each do |kanmusu|
             if id == kanmusu["api_id"]
               sortno = kanmusu["api_sortno"]
               break
             end
          end
          start2_json["api_data"]["api_mst_ship"].reverse_each do |kanmusu|
            if sortno == kanmusu["api_sortno"]
              names[i] = kanmusu["api_name"]
              Kanmusu::kanmusu_names_push(id,kanmusu["api_name"])
              break
            end
          end
        end
      end
      names
    end
    def read_rengeki(hougeki1, hougeki2)
      kanmusu_rengeki = Array.new(6).map{Array.new(@file.length).map{0}}

      [ hougeki1, hougeki2 ].each do |hougeki|
        for i in 0..hougeki.length-1
          next if hougeki[i].nil?
          # 連撃をし、攻撃が味方の場合
          for j in 0..hougeki[i][:cl_list].length-1
            if hougeki[i][:damage][j].length == 2 &&
                (1 <= hougeki[i][:at_list][j] && hougeki[i][:at_list][j] <= 6)
              kanmusu_rengeki[hougeki[i][:at_list][j]-1][i] += 1
            end
          end
        end
      end

      kanmusu_rengeki.map{|rengeki| rengeki.inject(:+) }
    end
    def read_battle_forms(file_json)
      forms = Array.new
      file_json.each do |file_json|
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
    def read_seiku(file)
      seiku = Array.new
      file.each do |file_json|
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
      seiku
    end
    def read_exps(port_json, end_port_json)
      exps = Array.new(6)
      s_exp = Array.new(6)
      e_exp = Array.new(6)

      ids.each_with_index do |id, i|
        s_exp[i] = port_ship(id, "api_exp", port_json)
        e_exp[i] = port_ship(id, "api_exp", end_port_json)
      end
      for i in 0..5
        if s_exp[i].nil? || e_exp[i].nil?
          exps[i] = nil
        else
          exps[i] = e_exp[i][0]-s_exp[i][0]
        end
      end
      exps
    end
    # port_fileから現在の経験値を返す
    def read_now_exps(key, port_json, end_port_json)
      case key
      when :start
        @ids.map{|id| if (a = port_ship(id, "api_exp", port_json)).nil? then nil else a[0] end}
      when :end
        @ids.map{|id| if (a = port_ship(id, "api_exp", end_port_json)).nil? then nil else a[0] end}
      end
    end

    def read_hougeki1(file)
      hou = Array.new
      file.each_with_index do |file_json, i|
        battle = Hash.new
        if file_json[:battle].nil? || file_json[:battle]["api_data"]["api_hourai_flag"][0] != 1
          battle = nil
        else
          file_json[:battle]["api_data"]["api_hougeki1"].each do |key, value|
            battle[key.slice(4, key.length).to_sym] = value.select{|v| v != -1 }
          end
        end
        hou[i] = battle
      end
      hou
    end
    def read_hougeki2(file)
      hou = Array.new
      file.each_with_index do |file_json, i|
        battle = Hash.new
        if file_json[:battle].nil? || file_json[:battle]["api_data"]["api_hourai_flag"][1] != 1
          battle = nil
        else
          file_json[:battle]["api_data"]["api_hougeki2"].each do |key, value|
            value.shift
            battle[key.slice(4, key.length).to_sym] = value.select{|v| v != -1 }
          end
        end
        hou[i] = battle
      end
      hou
    end
    def lost_resources(port_json, key)
      # lv10未満は飛ばす
      data = Array.new(6).map{0}
      kanmusu_json = port_json["api_data"]["api_ship"]
      @ids.each_with_index do |id, i|
        next if id == -1 || @lvs[i] < 10
        if id > Kanmusu::port_kanmusu_iti_last_id
          kanmusu_json.reverse_each do |kanmusu|
            break if kanmusu["api_id"] <= Kanmusu::port_kanmusu_iti_last_id
            if kanmusu["api_id"] == id
              if kanmusu[key].is_a?(Array)
                data[i] = kanmusu[key].inject(:+)
              else
                data[i] = kanmusu[key]
              end
            end
          end
        else
          if kanmusu_json[Kanmusu::port_kanmusu_iti(id)][key].is_a?(Array)
            data[i] = kanmusu_json[Kanmusu::port_kanmusu_iti(id)][key].inject(:+)
          else
            data[i] = kanmusu_json[Kanmusu::port_kanmusu_iti(id)][key]
          end
        end
      end
    end
    # portファイルのspi_shipからデータを取得
    def port_ship(id, key, port_json)
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
    # 現在は 名前だけ
    def start2_slotitem(id, slotitem_member_json, start2_json, end_slotitem_member_json)
      if id > Kanmusu::start2_slot_iti_last_id
        sortno = nil
        slotitem_member_json["api_data"].reverse_each do |slot|
          if slot["api_id"] == id
            sortno = slot["api_slotitem_id"]
            break
          end
        end
        start2_json["api_data"]["api_mst_slotitem"].reverse_each do |slot|
          if slot["api_sortno"] == sortno
            return slot["api_name"]
          end
        end
        return "不明。見つからず"
      elsif id != -1
        if Kanmusu::start2_slot_iti[id].nil?
          sortno = nil
          slotitem_member_json["api_data"].reverse_each do |slot|
            if slot["api_id"] == id
              sortno = slot["api_slotitem_id"]
              break
            end
          end
          start2_json["api_data"]["api_mst_slotitem"].reverse_each do |slot|
            if slot["api_sortno"] == sortno
              return slot["api_name"]
            end
          end
          sortno = nil
          end_slotitem_member_json["api_data"].reverse_each do |slot|
            if slot["api_id"] == id
              sortno = slot["api_slotitem_id"]
              break
            end
          end
          start2_json["api_data"]["api_mst_slotitem"].reverse_each do |slot|
            if slot["api_sortno"] == sortno
              return slot["api_name"]
            end
          end
          return "不明。見つからず"
        else
          return Kanmusu::start2_slot_iti[id]
        end
      else
        return nil
      end
    end
    ##################################################################
    # end インスタンスメソッド                                       #
    ##################################################################
  end
end
