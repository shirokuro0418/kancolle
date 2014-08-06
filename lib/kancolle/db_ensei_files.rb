# -*- coding: utf-8 -*-
## DBから遠征データを扱うクラス

module Kancolle
  class DbEnseiFiles < Array

    def initialize(ensei_files = nil)
      ensei_files = DbConnection::ensei_today if ensei_files.nil?
      super(ensei_file.length){ensei_files}
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

      self.map{|enesi_file| db.exec("SELECT * FROM item WHERE id = #{ensei_file.item1_id}")[0].item_name}
    end
  end
end
