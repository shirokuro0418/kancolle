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
      lv = Array.new
      @port_json["api_data"]["api_ship"].each do |kanmusu|
        ids.each_with_index do |id, i|
          if kanmusu["api_id"] == id
            lv[i] = kanmusu["api_lv"]
          end
        end
      end
      lv
    end
    # ボーキサイト
    def lost_bauxites
      max_onslot = Array.new(6).map{0}
      now_onslot = Array.new(6).map{0}
      # MAXのスロット数合計
      @start2_json["api_data"]["api_mst_ship"].each do |def_kanmusu|
        names.each_with_index do |name, i|
          max_onslot[i] = def_kanmusu["api_maxeq"].inject(:+) if def_kanmusu["api_name"] == name
        end
      end
      # 現在のスロット数合計
      @end_port_json["api_data"]["api_ship"].each do |kanmusu|
        ids.each_with_index do |id, i|
          if kanmusu["api_id"] == id
            now_onslot[i] = kanmusu["api_onslot"].inject(:+)
          end
        end
      end
      max_onslot.map.with_index{|slot, i| (slot - now_onslot[i]) * 5 unless slot.nil?}
    end
    # 燃料
    def lost_fuels
      now_fuels = Array.new(6).map{0}
      max_fuels = Array.new(6).map{0}
      # 出撃時の燃料
      @port_json["api_data"]["api_ship"].each do |kanmusu|
        ids.each_with_index do |id, i|
          if kanmusu["api_id"] == id
            max_fuels[i] = kanmusu["api_fuel"]
          end
        end
      end
      # 現在燃料
      @end_port_json["api_data"]["api_ship"].each do |kanmusu|
        ids.each_with_index do |id, i|
          if kanmusu["api_id"] == id
            now_fuels[i] = kanmusu["api_fuel"]
          end
        end
      end
      # ケッコン艦は15%off
      lvs.each_with_index do |lv, i|
        now_fuels[i] = (max_fuels[i] - ((max_fuels[i] - now_fuels[i]) * 0.85).to_i) if lv > 99
      end
      max_fuels.map.with_index{|m_fuel, i| m_fuel - now_fuels[i]}
    end
    # 弾薬
    def lost_bulls
      max_bull = Array.new(6).map{nil}
      now_bull = Array.new(6).map{nil}
      # MAXのスロット数合計
      @start2_json["api_data"]["api_mst_ship"].each do |def_kanmusu|
        names.each_with_index do |name, i|
          max_bull[i] = def_kanmusu["api_bull_max"] if def_kanmusu["api_name"] == name
        end
      end
      # 現在のスロット数合計
      @end_port_json["api_data"]["api_ship"].each do |kanmusu|
        ids.each_with_index do |id, i|
          if kanmusu["api_id"] == id
            now_bull[i] = kanmusu["api_bull"]
          end
        end
      end
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
      return route
    end
    # 名前
    def names
      names        = Array.new(6).map{nil}
      id_names     = Array.new(6).map{nil}
      sortno_names = Array.new(6).map{nil}
      id_names = @port_json["api_data"]["api_deck_port"][0]["api_ship"]
      @port_json["api_data"]["api_ship"].each do |kanmusu|
        id_names.each_with_index do |id_name, i|
          sortno_names[i] = kanmusu["api_sortno"] if id_name == kanmusu["api_id"]
        end
      end
      @start2_json["api_data"]["api_mst_ship"].each do |kanmusu|
        sortno_names.each_with_index do |sortno_name, i|
          names[i] = kanmusu["api_name"] if sortno_name == kanmusu["api_sortno"]
        end
      end
      return names
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

    private
    # JSONを読み込み
    # def json_read
    #   open(@start) {|p| @start_json  = JSON::parse(p.read)} if @start_json.empty?
    #   open(@start2){|p| @start2_json = JSON::parse(p.read)} if @start2_json.empty?
    #   open(@port)  {|p| @port_json   = JSON::parse(p.read)} if @port_json.empty?
    #   open(@slotitem_member){|p| @slotitem_member_json = JSON::parse(p.read)} if @slotitem_member_json.empty?
    #   if @file_json.empty?
    #     @file.each_with_index do |mass, i|
    #       mass_json = Hash.new
    #       mass.each do |key, value|
    #         unless value.nil?
    #           open(value){|j| mass_json[key] = JSON::parse(j.read)}
    #         else
    #           mass_json[key] = nil
    #         end
    #       end
    #       @file_json[i] = mass_json
    #     end
    #   end
    # end
    def ids
      @port_json["api_data"]["api_deck_port"][0]["api_ship"]
    end
    def return_json(key, x)
      if @json_data[key].nil? then json_read(key) end
      if x.nil? then return @json_data[key] else return @json_data[key][x] end
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

    ##################################################################
    # end インスタンスメソッド                                       #
    ##################################################################
  end
end
