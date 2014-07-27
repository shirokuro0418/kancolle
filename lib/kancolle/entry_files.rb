# -*- coding: utf-8 -*-
## EntryFileの集まり

module Kancolle
  class EntryFiles
    attr_reader :entry_files

    def initialize(datas = nil)
      if datas.nil?
        @entry_files = Array.new
      else
        @entry_files = datas
      end
    end

    ##################################################################
    # インスタンスメソッド                                           #
    ##################################################################
    # ステージで検出
    def extract_stage(maparea, mapinfo = nil)
      entry_files = Array.new
      @entry_files.each do |entry_file|
        map = entry_file.map
        if map[0] == maparea
          if mapinfo.nil? || map[1] == mapinfo
            entry_files.push(entry_file)
          end
        end
      end
      return EntryFiles.new(entry_files)
    end
    # ルートで検出
    def extract_route(route)
      EntryFiles.new(@entry_files.select {|entry_file| entry_file.route == route})
    end
    def length
      @entry_files.length
    end
    # ボーキサイト
    def lost_bauxites
      @entry_files.map{|entry_file| entry_file.lost_bauxites}
    end
    # 燃料
    def lost_fuels
      @entry_files.map{|entry_file| entry_file.lost_fuels}
    end
    # 弾薬
    def lost_bulls
      @entry_files.map{|entry_file| entry_file.lost_bulls}
    end
    # ルート
    def routes
      @entry_files.map{|entry_file| entry_file.route}
    end
    # 名前
    def names
      @entry_files.map{|entry_file| entry_file.names}
    end
    def names_low
      @entry_files.map{|entry_file| entry_file.names_low}
    end
    # 装備
    def slots
      @entry_files.map{|entry_file| entry_file.slots}
    end
    # 航戦形態
    def battle_forms
      @entry_files.map{|entry_file| entry_file.battle_forms}
    end
    # 制空権
    def seiku
      @entry_files.map{|entry_file| entry_file.seiku}
    end
    # 獲得経験値合計
    def exps
      @entry_files.map{|entry_file| entry_file.exps_low}
    end
    # 指定した艦のexp合計
    def exp(name, name2 = nil)
      s_exp = nil
      e_exp = nil
      @entry_files.each do |entry_file|
        if entry_file.names.include?(name)
          all_exps = entry_file.now_exps(:start)
          num = nil
          entry_file.names.each_with_index{|n,i| num = i if name == n}
          s_exp = all_exps[num][0]
          break
        end
      end
      @entry_files.reverse_each do |entry_file|
        name = name2 unless name2.nil?
        if entry_file.names_low.include?(name)
          all_exps = entry_file.now_exps(:end)
          num = nil
          entry_file.names_low.each_with_index{|n,i| num = i if name == n}
          e_exp = all_exps[num][0]
          break
        end
      end
      e_exp - s_exp
    end
    # 判定
    def hantei
      hantei = Array.new
      @entry_files.each {|entry_file| hantei.push(entry_file.hantei)}
      return hantei
    end
    # 今日の出撃
    def today
      EntryFiles.new(@entry_files.
                     select{ |entry_file|
                       Date.today == Date.parse(entry_file.start.sub(/^.*\//, '').sub(/_.*json$/, ''))
                     })
    end
    # 日付指定 Dateクラスを引数に
    def day(date)
      EntryFiles.new(@entry_files.
                     select{ |entry_file|
                       date == Date.parse(entry_file.start.sub(/^.*\//, '').sub(/_.*json$/, ''))
                     })
    end
    # 期間指定 Dateクラスを引数に
    def between_days(s_day, e_day)
      if e_day < s_day
        return EntryFile.new
      else
        EntryFiles.new(@entry_files.select{|entry_file|
                         entry_file_day = Date.parse(entry_file.start.sub(/^.*\//, '').sub(/_.*json$/, ''))
                         s_day <= entry_file_day && entry_file_day <= e_day })
      end
    end
    # 指定した艦のlvの変動
    def lv(name, name2 = nil)
      s_lv = nil
      e_lv = nil
      @entry_files.each do |entry_file|
        if entry_file.names_low.include?(name)
          num = nil
          entry_file.names.each_with_index{|n,i| num = i if name == n}
          s_lv = entry_file.lvs[num]
          break
        end
      end
      @entry_files.reverse_each do |entry_file|
        name = name2 unless name2.nil?
        if entry_file.names_low.include?(name)
          num = nil
          entry_file.names_low.each_with_index{|n,i| num = i if name == n}
          e_lv = entry_file.lvs[num]
          break
        end
      end
      [s_lv, e_lv]
    end

    # ぷっしゅ
    def push(entry_files)
      entry_files.entry_files.each do |entry_file|
        @entry_files.push(entry_file)
      end
      @entry_files.sort!{|a, b| a.start.split('/').last <=> b.start.split('/').last}
    end
    # nil?
    def empty?
      @entry_files.empty?
    end
    ##################################################################
    # end インスタンスメソッド                                       #
    ##################################################################

  end
end
