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
      @entry_files.select {|entry_file| entry_file.route == route}
    end

    def length
      @entry_files.length
    end

    # ボーキサイト
    def bauxites
      bau = Array.new
      @entry_files.each do |entry_file|
        bau.push(entry_file.bauxite)
      end
      return bau
    end

    # ルート
    def routes
      routes = Array.new
      @entry_files.each do |entry_file|
        routes.push(entry_file.route)
      end
      return routes
    end
  end
end
