# -*- coding: utf-8 -*-
## DBからデータを扱うクラス

module Kancolle
  class DbEntryFile
    attr_reader :date, :ids, :map, :lvs, :lost_fuels, :lost_bulls, :lost_bauxites,
                :route, :names, :slots, :hantei, :rengeki, :battle_forms,
                :seiku, :exps, :now_exps, :now_exps_end, :got_fuel, :got_bull,
                :got_steel, :got_bauxisite,
                :start, :file, :start2, :slotitem_member, :end_slotitem_member,
                :port, :end_port

    def initialize(datas = {})
      integers = [ "got_fuel","got_bull","got_steel","got_bauxisite" ]
      strings  = [ "start", "start2", "slotitem_member", "end_slotitem_member",
                   "port", "end_port"
                 ]
      datas.each do |attribute_name, value|
        if attribute_name == "date"
          @date = Time::parse(value)
        else
          next if attribute_name == "id"

          if strings.include?(attribute_name)
            eval("@#{attribute_name} = '#{value}'")
          elsif integers.include?(attribute_name)
            eval("@#{attribute_name} = #{value}")
          elsif ["file"].include?(attribute_name)
            @file = Array.new
            next if value == "[]"
            i = 0
            while data = value.slice!(/{.*?}/)
              @file[i] = eval data
              i += 1
            end
          else
            eval("@#{attribute_name} = #{JSON::parse value.gsub(/nil/,'null')}")
          end
        end
      end
    end

    ##################################################################
    # インスタンスメソッド                                           #
    ##################################################################
    public
    def to_db
      h = Hash.new
      day = Time.local(year, man, day, other[0..1], other[2..3], other[4..5])
      h[:date] = day
      self.instance_variables.each do |var|
        h[var.to_s.sub(/@/, '')] = (eval var.to_s.sub(/@/, '').to_s).to_s
      end
      h
    end

    ##################################################################
    # private                                                        #
    ##################################################################
    private
    ##################################################################
    # end インスタンスメソッド                                       #
    ##################################################################
  end
end
