# -*- coding: utf-8 -*-
## DBから遠征データを扱うクラス

module Kancolle
  class DbEnseiFile
    attr_reader :ship_id, :date, :clear_result, :get_exp, :member_exp, :get_ship_exp,
                :maparea_name, :detail, :quest_name, :quest_level, :get_material,
                :item1_id, :count_item1, :item2_id, :count_item2, :quest_id

    def initialize(datas = {})
      arrays   = [ "ship_id", "get_ship_exp", "get_material" ]
      integers = [ "clear_result", "get_exp", "member_exp", "quest_level",
                   "item1_id", "count_item1", "item2_id", "count_item2",
                   "quest_id"
                 ]
      strings  = [ "maparea_name", "detail", "quest_name" ]
      datas.each do |attribute_name, value|
        if attribute_name == "date"
          @date = Time::parse(value)
        else
          next if attribute_name == "id"

          if strings.include?(attribute_name)
            eval("@#{attribute_name} = '#{value.rstrip}'")
          elsif integers.include?(attribute_name)
            if value.nil?
              eval("@#{attribute_name} = nil")
            else
              eval("@#{attribute_name} = #{value.to_i}")
            end
          elsif arrays.include?(attribute_name)
            eval("@#{attribute_name} = #{JSON::parse value.gsub(/nil/,'null').gsub(/{/,'[').gsub(/}/,']')}")
          else
            raise "error:わからない型 #{attribute_name}"
          end
        end
      end
    end
    ##################################################################
    # インスタンスメソッド                                           #
    ##################################################################
    def item1_name
      db = DbConnection::connect
      begin
        if @item1_id.nil?
          return nil
        else
          return db.exec("SELECT * FROM item WHERE id = #{@item1_id}")[0]["item_name"].rstrip
        end
      rescue => e
        puts "errer:#{e}"
      ensure
        db.close
      end
    end
    def item2_name
      db = DbConnection::connect
      begin
        if @item2_id.nil?
          return nil
        else
          return db.exec("SELECT * FROM item WHERE id = #{@item2_id}")[0]["item_name"].rstrip
        end
      rescue => e
        puts "errer:#{e}"
      ensure
        db.close
      end
    end
    ##################################################################
    # end インスタンスメソッド                                       #
    ##################################################################
  end
end
