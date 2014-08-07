# -*- coding: utf-8 -*-
## DBから遠征データを扱うクラス

module Kancolle
  class DbEnseiFiles < Array

    def initialize(ensei_files = nil)
      super(ensei_files)
    end

    ##################################################################
    # インスタンスメソッド                                           #
    ##################################################################
    def quest_names
      self.map{|ensei_file| ensei_file.quest_name}
    end
    def get_materials
      self.map{|ensei_file| ensei_file.get_material}
    end
    def item1_names
      db = DbConnection::connect

      begin
        return self.map do |enesi_file|
          if ensei_file.item1_id.nil?
            nil
          else
            db.exec("SELECT * FROM item WHERE id = #{ensei_file.item1_id}")[0]["item_name"].rstrip
          end
        end
      rescue => e
        puts "errer:#{e}"
      ensure
        db.close
      end
    end
  end
end
