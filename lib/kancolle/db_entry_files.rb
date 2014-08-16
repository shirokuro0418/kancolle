# -*- coding: utf-8 -*-
## EntryFileの集まり

module Kancolle
  class DbEntryFiles < Array
    # attr_reader :entry_files

    def initialize(entry_files = nil)
      super(entry_files)
    end

    ##################################################################
    # インスタンスメソッド                                           #
    ##################################################################
    # id
    def ids
      self.map{|entry_file| entry_file.ids}
    end
    # lvs
    def lvs
      self.map{|entry_file| entry_file.lvs}
    end
    # ステージで検出
    def extract_stage(maparea, mapinfo = nil)
      self.select do |entry_file|
        map = entry_file.map
        if map[0] == maparea
          if mapinfo.nil? || map[1] == mapinfo
            true
          else
            false
          end
        end
      end
    end
    # ルートで検出
    def extract_route(route)
      self.select {|entry_file| entry_file.route == route}
    end
    # 燃料
    def lost_fuels
      self.map{|entry_file| entry_file.lost_fuels}
    end
    # 弾薬
    def lost_bulls
      self.map{|entry_file| entry_file.lost_bulls}
    end
    # 鋼材
    def lost_steels
      self.map{|entry_file| entry_file.lost_steels}
    end
    # ボーキサイト
    def lost_bauxites
      self.map{|entry_file| entry_file.lost_bauxites}
    end

    # 回収資源
    def got_fuels
      self.map{|entry_file| entry_file.got_fuel}
    end
    def got_bulls
      self.map{|entry_file| entry_file.got_bull}
    end
    def got_steels
      self.map{|entry_file| entry_file.got_steel}
    end
    def got_bauxisites
      self.map{|entry_file| entry_file.got_bauxisite}
    end
    def maps
      self.map{|entry_file|entry_file.map}
    end

    # ルート
    def routes
      self.map{|entry_file| entry_file.route}
    end
    # 名前
    def names
      self.map{|entry_file| entry_file.names}
    end
    # 装備
    def slots
      self.map{|entry_file| entry_file.slots}
    end
    # 航戦形態
    def battle_forms
      self.map{|entry_file| entry_file.battle_forms}
    end
    # 制空権
    def seiku
      self.map{|entry_file| entry_file.seiku}
    end
    # 獲得経験値合計
    def exps
      self.map{|entry_file| entry_file.exps}
    end
    # 判定
    def hantei
      self.map{|entry_file| entry_file.hantei}
    end
    # 今日の出撃
    def today
      self.select{|entry_file| Date.today == Date.parse(entry_file.date.to_s) }
    end
    # 日付指定 Dateクラスを引数に
    def day(day)
      self.select{ |entry_file| day == Date.parse(entry_file.date.to_s) }
    end

    # 互角性のために非推奨
    def entry_files
      self
    end

    # 期間指定 Dateクラスを引数に
    def between_days(s_day, e_day)
      if e_day < s_day
        return DbEntryFile.new
      else
        new_entry_files = self.select do |entry_file|
          entry_file_day = Date.parse(entry_file.start.sub(/^.*\//, '').sub(/_.*json$/, ''))
          s_day <= entry_file_day && entry_file_day <= e_day
        end
        new_entry_files.sort{|a,b| a.start.sub(/^.*\//, '').sub(/_.*json$/, '')<=>b.start.sub(/^.*\//, '').sub(/_.*json$/, '')}
      end
    end
    ##################################################################
    # end インスタンスメソッド                                       #
    ##################################################################

  end
end
