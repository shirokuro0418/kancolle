# -*- coding: utf-8 -*-
## インスタンスメソッド
module Kancolle
  class FindEntryFile
    # def initialize(dir = nil)
    #   datas = find_entry_file_for_dir(dir)
    #   super(datas)
    # end

    public

    ## dirからEntryFile郡を作る
    def self.parse_for_dir(dir)
      if dir.nil?
        dir = "/Users/shirokuro11/Documents/koukai_nisshi/data/json/json"
      end

      entryfiles           = Array.new

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
              entryfiles.push(EntryFile.new({ "start" => start_file,
                                              "file" => syutugeki_arr,
                                              "start2" => start2_file,
                                              "slotitem_member" => start2_file,
                                              "port" => port_file }))
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
          entryfiles.push(EntryFile.new({ "start" => start_file,
                                          "file" => syutugeki_arr,
                                          "start2" => start2_file,
                                          "slotitem_member" => start2_file,
                                          "port" => port_file }))
        end
      end
      return entryfiles
    end
  end
end
