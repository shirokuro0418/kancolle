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

      # それぞれ使うときに一度だけ読み込む
      @json_data                = Hash.new
      @start_json               = lambda {|x=nil| return return_json(:start, x) }
      @start2_json              = lambda {|x=nil| return return_json(:start2, x) }
      @port_json                = lambda {|x=nil| return return_json(:port, x) }
      @slotitem_member_json     = lambda {|x=nil| return return_json(:slotitem_member, x) }
      @file_json                = lambda {|x=nil| return return_json(:file, x) }
      @end_port_json            = lambda {|x=nil| return return_json(:end_port, x) }
      @end_slotitem_member_json = lambda {|x=nil| return return_json(:end_slotitem_member, x) }
    end

    ##################################################################
    # インスタンスメソッド                                           #
    ##################################################################
    public
    # マップ情報 return [マップ番号、ステージ番号]
    def map
      return [@start_json["api_data"]["api_maparea_id"], @start_json["api_data"]["api_mapinfo_no"]]
    end
    # レベル
    def lvs
      lvs = Array.new(6).map{nil}
      ids.each_with_index do |id, i|
        lvs[i] = port_ship(id, "api_lv", @port_json)
      end
      lvs
    end
    # ボーキサイト
    def lost_bauxites
      max_onslot = Array.new(6).map{0}
      now_onslot = Array.new(6).map{0}
      # MAXのスロット数合計 lv 10未満は飛ばす
      lost_resources!(max_onslot, @port_json, "api_onslot")
      # 現在のスロット数合計 lv 10未満は飛ばす
      lost_resources!(now_onslot, @end_port_json, "api_onslot")

      max_onslot.map.with_index{|slot, i| (slot - now_onslot[i]) * 5 unless slot.nil?}
    end
    # 燃料
    def lost_fuels
      now_fuels = Array.new(6).map{0}
      max_fuels = Array.new(6).map{0}
      # 出撃時の燃料 lv 10未満は飛ばす
      lost_resources!(max_fuels, @port_json, "api_fuel")
      # 現在燃料 lv 10未満は飛ばす
      lost_resources!(now_fuels, @end_port_json, "api_fuel")
      # ケッコン艦は15%off
      lvs.each_with_index do |lv, i|
        now_fuels[i] = (max_fuels[i] - ((max_fuels[i] - now_fuels[i]) * 0.85).to_i) if lv > 99
      end
      max_fuels.map.with_index{|m_fuel, i| m_fuel - now_fuels[i]}
    end
    # 弾薬
    def lost_bulls
      max_bull = Array.new(6).map{0}
      now_bull = Array.new(6).map{0}
      # 出撃時の弾薬 lv 10未満は飛ばす
      lost_resources!(max_bull, @port_json, "api_bull")
      # 現在の弾薬 lv 10未満は飛ばす
      lost_resources!(now_bull, @end_port_json, "api_bull")
      # ケッコン艦は15%off
      lvs.each_with_index do |lv, i|
        now_bull[i] = (max_bull[i] - ((max_bull[i] - now_bull[i]) * 0.85).to_i) if lv > 99
      end

      max_bull.map.with_index{|slot, i| slot - now_bull[i]}
    end
    # ルート
    def route
      route = Array.new
      route.push(@start_json["api_data"]["api_no"])
      tmp_file = @file_json.call.clone
      tmp_file.shift
      tmp_file.each do |file_json|
        route.push(file_json[:next]["api_data"]["api_no"])
      end
      route
    end
    # 名前
    def names
      names = Array.new(6).map{nil}

      ids.each_with_index do |id, i|
        if id == -1
          next
        elsif !(names[i] = Kanmusu::kanmusu_names[id]).nil?
        else
          sortno = nil
          @port_json["api_data"]["api_ship"].reverse_each do |kanmusu|
             if id == kanmusu["api_id"]
               sortno = kanmusu["api_sortno"]
               break
             end
          end
          @start2_json["api_data"]["api_mst_ship"].reverse_each do |kanmusu|
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
    # 改、改二のみ 阿武隈は例外
    def names_low
      names = Array.new(6).map{nil}

      ids.each_with_index do |id, i|
        if id == -1
          next
        elsif (name=Kanmusu::kanmusu_names[id]) =~ /改/ || name =~ /阿武隈/
          names[i] = name
        else
        end
      end
      names
    end
    # 装備名
    def slots
      slot_ids = Array.new(6).map{nil}
      ids.each_with_index do |id, i|
        slot_ids[i] = port_ship(id, "api_slot", @port_json)
      end

      slot_names = Array.new(6).map{Array.new(5)}
      slot_ids.each_with_index do |kanmusu_slot, i|
        if kanmusu_slot.nil?
          slot_names[i] = nil
        else
          kanmusu_slot.each_with_index do |slot_id, j|
            slot_names[i][j] = start2_slotitem(slot_id)
          end
        end
      end
      return slot_names
    end
    # 勝利判定
    def hantei
      hantei = Array.new
      @file_json.call.each_with_index do |file_json, i|
        if file_json[:battle].nil?
          hantei[i] = nil
        else
          hantei[i] = Hantei::syouri(file_json[:battle], file_json[:battle_midnight])
        end
      end
      return hantei
    end
    # 砲撃１
    def hougeki1
      hou = Array.new
      @file_json.call.each_with_index do |file_json, i|
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
    # 砲撃2
    def hougeki2
      hou = Array.new
      @file_json.call.each_with_index do |file_json, i|
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
    # 連撃
    def rengeki
      kanmusu_rengeki = rengeki_at_stage
      kanmusu_rengeki.map{|rengeki| rengeki.inject(:+) }
    end
    def rengeki_at_stage
      kanmusu_rengeki = Array.new(6).map{Array.new(@file.length).map{0}}

      [ hougeki1, hougeki2 ].each do |hou|
        for i in 0..hou.length-1
          next if hou[i].nil?
          # 連撃をし、攻撃が味方の場合
          for j in 0..hou[i][:cl_list].length-1
            if hou[i][:damage][j].length == 2 && (1 <= hou[i][:at_list][j] && hou[i][:at_list][j] <= 6)
              kanmusu_rengeki[hou[i][:at_list][j]-1][i] += 1
            end
          end
        end
      end
      kanmusu_rengeki
    end
    # 交戦形態
    def battle_forms
      forms = Array.new
      @file_json.call.each do |file_json|
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
    # 制空権
    def seiku
      seiku = Array.new
      @file_json.call.each do |file_json|
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
          end
        else
          seiku.push(nil)
        end
      end
      seiku
    end
    # 獲得合計経験値
    def exps
      exps = Array.new
      s_exp = Array.new(6)
      e_exp = Array.new(6)

      ids.each_with_index do |id, i|
        s_exp[i] = port_ship(id, "api_exp", @port_json)
        e_exp[i] = port_ship(id, "api_exp", @end_port_json)
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
    def now_exps(key)
      case key
      when :start
        ids.map{|id| if (a = port_ship(id, "api_exp", @port_json)).nil? then nil else a[0] end}
      when :end
        ids.map{|id| if (a = port_ship(id, "api_exp", @end_port_json)).nil? then nil else a[0] end}
      end
    end
    # 新しい艦は含めない
    def exps_low
      exps = Array.new
      s_exp = Array.new(6)
      e_exp = Array.new(6)

      ids.each_with_index do |id, i|
        next if id > 24819
        s_exp[i] = port_ship(id, "api_exp", @port_json)
        e_exp[i] = port_ship(id, "api_exp", @end_port_json)
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

    private
    def ids
      @port_json["api_data"]["api_deck_port"][0]["api_ship"]
    end
    def return_json(key, x)
      if @json_data[key].nil? then json_read(key) end
      if x.nil?
        @json_data[key]
      else
        @json_data[key][x]
      end
    end
    def json_read(key)
      case key
      when :start
        open(@start) {|j| @json_data[key] = JSON::parse(j.read)}
      when :start2
        open(@start2) {|j| @json_data[key] = JSON::parse(j.read)}
      when :port
        open(@port) {|j| @json_data[key] = JSON::parse(j.read)}
      when :slotitem_member
        open(@slotitem_member) {|j| @json_data[key] = JSON::parse(j.read)}
      when :file
        @json_data[key] = Array.new
        @file.each_with_index do |mass, i|
          mass_json = Hash.new
          mass.each do |mass_key, mass_value|
            if mass_value.nil?
              mass_json[mass_key] = nil
            else
              open(mass_value){|j| mass_json[mass_key] = JSON::parse(j.read)}
            end
          end
          @json_data[key][i] = mass_json
        end
      when :end_port
        open(@end_port) {|j| @json_data[key] = JSON::parse(j.read)}
      when :end_slotitem_member
        open(@end_slotitem_member) {|j| @json_data[key] = JSON::parse(j.read)}
      end
    end
    def lost_resources!(data, port_json, key)
      kanmusu_json = port_json["api_data"]["api_ship"]
      ids.each_with_index do |id, i|
        next if lvs[i] < 10
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
      if id == -1
        return nil
      elsif !(Kanmusu::port_kanmusu_iti(id).nil?)
        # 念のため一致してるかチェック
        if id == port_json["api_data"]["api_ship"][Kanmusu::port_kanmusu_iti(id)]["api_id"]
          return port_json["api_data"]["api_ship"][Kanmusu::port_kanmusu_iti(id)][key]
        else
          port_json["api_data"]["api_ship"].reverse_each.with_index do |kanmusu,i|
            if kanmusu["api_id"] == id
              Kanmusu::port_kanmusu_iti_push(id, port_json["api_data"]["api_ship"].length-i-1)
              return kanmusu[key]
            end
          end
        end
      else
        port_json["api_data"]["api_ship"].each_with_index do |kanmusu, i|
          if kanmusu["api_id"] == id
            Kanmusu::port_kanmusu_iti_push(id, i)
            return kanmusu[key]
          end
        end
      end
      return nil
    end
    # 現在は 名前だけ
    def start2_slotitem(id)
      if id > Kanmusu::start2_slot_iti_last_id
        sortno = nil
        @slotitem_member_json["api_data"].reverse_each do |slot|
           if slot["api_id"] == id
             sortno = slot["api_slotitem_id"]
             break
           end
        end
        @start2_json["api_data"]["api_mst_slotitem"].reverse_each do |slot|
          if slot["api_sortno"] == sortno
            return slot["api_name"]
          end
        end
      elsif id != -1
        return Kanmusu::start2_slot_iti[id]
      else
        return nil
      end
    end
    ##################################################################
    # end インスタンスメソッド                                       #
    ##################################################################
  end
end
