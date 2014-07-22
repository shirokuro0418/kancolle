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
      routes = Array.new
      @entry_files.each do |entry_file|
        routes.push(entry_file.route)
      end
      return routes
    end
    # 名前
    def names
      names = Array.new
      @entry_files.each do |entry_file|
        names.push(entry_file.names)
      end
      return names
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
                         s_day <= Date.parse(entry_file.start.sub(/^.*\//, '').sub(/_.*json$/, '')) &&
                         Date.parse(entry_file.start.sub(/^.*\//, '').sub(/_.*json$/, '')) <= e_day })
      end
    end
    ##################################################################
    # end インスタンスメソッド                                       #
    ##################################################################

  end
end
