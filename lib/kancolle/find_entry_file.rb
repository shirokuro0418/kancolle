# -*- coding: utf-8 -*-
## インスタンスメソッド
# extract(maparea, mapinfo)
#     maparea => マップエリア
#     mapinfo => マップステージ
module Kancolle
  class FindEntryFile < Kancolle::EntryFile
    def initialize(dir = nil)
      datas = find_entry_file_for_dir(dir)
      super(datas)
    end

    public

    # ステージを指定して抽出
    def extract(maparea, mapinfo = nil)
      start           = Array.new
      file            = Hash.new
      start2          = Hash.new
      slotitem_member = Hash.new
      port            = Hash.new
      @start.each_with_index do |start_file, i|
        open(start_file) do |json|
          start_json = JSON::parse(json.read)
          if start_json["api_data"]["api_maparea_id"] == maparea
            if mapinfo.nil? || start_json["api_data"]["api_mapinfo_no"] != mapinfo
              next
            else
              start.push(start_file)
              file[start_file]            = @file[start_file]
              start2[start_file]          = @start2[start_file]
              slotitem_member[start_file] = @slotitem_member[start_file]
              port[start_file]            = @port[start_file]
            end
          end
        end
      end
      return EntryFile.new({
                             "start"           => start,
                             "file"            => file,
                             "start2"          => start2,
                             "slotitem_member" => slotitem_member,
                             "port"            => port
      })
    end

    private

    def find_entry_file_for_dir(dir)
      if dir.nil?
        dir = "/Users/shirokuro11/Documents/koukai_nisshi/data/json/json"
      end

      start_arr            = Array.new
      file_hash            = Hash.new
      start2_hash          = Hash.new
      slotitem_member_hash = Hash.new
      port_hash            = Hash.new

      Dir.open(dir) do |dir|
        start2_file          = nil
        port_file            = nil
        slotitem_member_file = nil
        start_file           = nil
        next_file            = nil
        ship2_file           = nil
        battle_file          = nil
        syutugeki_arr        = nil

        dir.sort.each do |file|
          start2_file          = dir.path + "/" + file if file =~ /_START2.json$/ # start2ファイルの抽出
          port_file            = dir.path + "/" + file if file =~ /_PORT.json$/     # portファイルの輸出
          slotitem_member_file = dir.path + "/" + file if file =~ /_SLOTITEM_MEMBER.json$/ # SLOTITEM_MEMBERの輸出
          ship2_file           = dir.path + "/" + file if file =~ /_SHIP2.json/
          battle_file          = dir.path + "/" + file if file =~ /_BATTLE.json/

          if file =~ /_START.json$/
            unless syutugeki_arr.nil?
              start_arr.push(start_file)
              file_hash[start_file]            = syutugeki_arr
              start2_hash[start_file]          = start2_file
              slotitem_member_hash[start_file] = slotitem_member_file
              port_hash[start_file]            = port_file
            end
            start_file    = dir.path + "/" + file
            syutugeki_arr = Array.new
          end

          # nextファイルからステージ情報の輸出
          if file =~ /_NEXT.json$/
            unless next_file.nil?
              syutugeki_arr.push({ :battle          => nil,
                                   :battle_result   => nil,
                                   :next            => next_file,
                                   :ship2           => ship2_file,
                                 })
            end
            next_file = dir.path + "/" + file
          end

          # battleファイルの輸出
          if file =~ /_BATTLE_RESULT.json$/
            syutugeki_arr.push({ :battle          => battle_file,
                                 :battle_result   => dir.path + "/" + file,
                                 :next            => next_file,
                                 :ship2           => ship2_file,
                               })
            next_file = nil
            battle_file = nil
          end
        end
        unless syutugeki_arr.nil?
          start_arr.push(start_file)
          file_hash[start_file]            = syutugeki_arr
          start2_hash[start_file]          = start2_file
          slotitem_member_hash[start_file] = slotitem_member_file
          port_hash[start_file]            = port_file
        end
      end
      return {
        "start" => start_arr,
        "file" => file_hash,
        "start2" => start2_hash,
        "slotitem_member" => slotitem_member_hash,
        "port" => port_hash
      }
    end
  end
end
