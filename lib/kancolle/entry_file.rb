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
    attr_reader :start, :file, :start2, :slotitem_member,  :end_slotitem_member, :port, :end_port

    def initialize(datas = {})
      super(datas)

      @ids           = Array.new
      @map           = Array.new # マップ情報 return [マップ番号、ステージ番号]
      @lvs           = Array.new
      # 失った資源
      @lost_fuels    = Array.new
      @lost_bulls    = Array.new
      @lost_steels   = Array.new
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
    def lost_steels
      read_all
      @lost_steels
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
      h = Hash.new
      year, man, day, other = @start.sub(/^.*\//, '').sub(/\..*$/, '').sub!(/_/, '-').split('-')
      day = Time.local(year, man, day, other[0..1], other[2..3], other[4..5])
      h[:date] = day
      self.instance_variables.each do |var|
        key = var.to_s.sub(/@/, '')
        var.to_s.sub(/@/, '').to_s
        h[key] = (eval var.to_s.sub(/@/, '').to_s)
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
        # file_jsonの読み込み
        unless start_json["api_data"]["api_maparea_id"] == 27 && [3,4,5].include?(start_json["api_data"]["api_mapinfo_no"])
          file_json                 = Array.new(@file.length)
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
        else
          file_json = nil
        end
        json = {
          :start2              => start2_json,
          :port                => port_json,
          :end_port            => end_port_json,
          :start               => start_json,
          :slotitem_member     => slotitem_member_json,
          :end_slotitem_member => end_slotitem_member_json,
          :file                => file_json
        }

        @ids = port_json["api_data"]["api_deck_port"][0]["api_ship"]
        @map = [start_json["api_data"]["api_maparea_id"], start_json["api_data"]["api_mapinfo_no"]]
        @lvs = @ids.map{|id| if id.nil? then nil else port_ship(id, "api_lv", port_json) end }
        @lost_fuels    = LostFuels.read(json) # read_lost_resources(port_json, end_port_json, "api_fuel")
        @lost_bulls    = read_lost_resources(port_json, end_port_json, "api_bull")
        @lost_steels   = LostSteels.read(json)
        @lost_bauxites = read_lost_bauxites(port_json, end_port_json)

        @route         = Route.read(json) # read_route(start_json, file_json)
        @names         = read_names(port_json, start2_json)
        @slots         = Array.new(6).map{Array.new(5)}
        # slotsの読み込み
        @ids.map{|id| port_ship(id, "api_slot", port_json)}.each_with_index do |kanmusu_slot, i|
          if kanmusu_slot.nil?
            @slots[i] = nil
          else
            kanmusu_slot.each_with_index do |slot_id, j|
              @slots[i][j] = start2_slotitem(slot_id, slotitem_member_json, start2_json, end_slotitem_member_json)
            end
          end
        end
        @hantei           = Hantei.read(json)
        @rengeki          = Rengeki.read(json)
        @battle_forms     = BattleForms.read(json) # read_battle_forms(file_json)
        @seiku            = Seiku.read(json) # read_seiku(file_json)
        @exps             = read_exps(port_json, end_port_json)
        @now_exps         = read_now_exps(:start, port_json, end_port_json)
        @now_exps_end     = read_now_exps(:end, port_json, end_port_json)

        # ステージで拾った資源
        case @map
        when [1,4]
          got_resource!(:bull,  [3], start_json, file_json)
          got_resource!(:steel, [4,11], start_json, file_json)
          got_resource!(:bauxisite, [6], start_json, file_json)
        when [2,2]
          got_resource!(:bauxisite, [2,3,8], start_json, file_json)
        when [2,3]
          got_resource!(:fuel, [2,6,7], start_json, file_json)
          got_resource!(:bull, [4,8], start_json, file_json)
        when [3,2]
          got_resource!(:steel, [5], start_json, file_json)
        when [4,2]
          got_resource!(:steel, [4,5,10], start_json, file_json)
        when [5,4]
          got_resource!(:fuel, [18], start_json, file_json)
        else
        end
      end
    end

    def read_json(file)
      open(file) do |f|
        return JSON::parse(f.read)
      end
    end
    def read_lost_resources(port_json, end_port_json, key_name)
      # lv10未満は飛ばす
      now_resources = lost_resources(port_json, key_name)
      end_resources = lost_resources(end_port_json, key_name)
      # ケッコン艦は15%off
      @lvs.each_with_index do |lv, i|
        next if lv.nil?
        end_resources[i] = (now_resources[i] - ((now_resources[i] - end_resources[i]) * 0.85).to_i) if lv > 99
      end
      now_resources.map.with_index{|m_fuel, i| m_fuel - end_resources[i]}
    end
    def read_lost_bauxites(port_json, end_port_json)
      # lv10未満は飛ばす
      max_onslot = lost_resources(port_json, "api_onslot")
      now_onslot = lost_resources(end_port_json,"api_onslot")

      max_onslot.each_with_index{|onslot, i| max_onslot[i] = onslot.inject(:+) if 0 != onslot}
      now_onslot.each_with_index{|onslot, i| now_onslot[i] = onslot.inject(:+) if 0 != onslot}

      max_onslot.map.with_index{|slot, i| (slot - now_onslot[i]) * 5 unless slot.nil?}
    end
    def read_names(port_json, start2_json)
      names = Array.new(6).map{nil}

      @ids.each_with_index do |id, i|
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
    def read_exps(port_json, end_port_json)
      exps = Array.new(6)
      s_exp = Array.new(6)
      e_exp = Array.new(6)

      @ids.each_with_index do |id, i|
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
      @ids.each_with_index do |id, i|
        next if id == -1 || @lvs[i] < 10
        port_json["api_data"]["api_ship"].each do |kanmusu|
          if kanmusu["api_id"] == id
            data[i] = kanmusu[key]
            break
          end
        end
      end
      data
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
    # read_all内の出撃で得た資源
    def got_resource!(key, map_route, start_json, file_json)
      @route.each_with_index do |route, i|
        if map_route.include?(route)
          if i == 0
            @got_fuel  += start_json["api_data"]["api_itemget"]["api_getcount"] if key == :fuel
            @got_bull  += start_json["api_data"]["api_itemget"]["api_getcount"] if key == :bull
            @got_steel += start_json["api_data"]["api_itemget"]["api_getcount"] if key == :steel
            @got_bauxisite  += start_json["api_data"]["api_itemget"]["api_getcount"] if key == :bauxisite
          else
            @got_fuel  += file_json[i][:next]["api_data"]["api_itemget"]["api_getcount"] if key == :fuel
            @got_bull  += file_json[i][:next]["api_data"]["api_itemget"]["api_getcount"] if key == :bull
            @got_steel += file_json[i][:next]["api_data"]["api_itemget"]["api_getcount"] if key == :steel
            @got_bauxisite += file_json[i][:next]["api_data"]["api_itemget"]["api_getcount"] if key == :bauxisite
          end
        end
      end
    end
    ##################################################################
    # end インスタンスメソッド                                       #
    ##################################################################
  end
end
