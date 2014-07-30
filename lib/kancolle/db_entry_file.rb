# -*- coding: utf-8 -*-
## DBからデータを扱うクラス

module Kancolle
  class DbEntryFile
    attr_reader :date, :ids, :map, :lvs, :lost_fuels, :lost_bulls, :lost_bauxites,
                :route, :names, :slots, :hantei, :rengeki, :battle_forms,
                :seiku, :exps, :now_exps, :now_exps_end, :got_fuel, :got_bull,
                :got_steel, :got_bauxisite

    def initialize(datas = {})
      datas.each do |attribute_name, value|
        if attribute_name == "date"
          @date = Date::parse(value)
        else
          next if attribute_name == "id"

          if ["got_fuel","got_bull","got_steel","got_bauxisite"].include?(attribute_name)
            eval("@#{attribute_name} = #{value}")
          else
            eval("@#{attribute_name} = #{JSON::parse value.gsub(/nil/, "null")}")
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
