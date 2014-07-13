# -*- coding: utf-8 -*-
module Kancolle
  class Find_entry_file
    # @start startファイルの配列
    # @file @start[x]をkeyとした１出撃のファイル群
    # @file[@start[x]][x][ :start2          ]
    #                    [ :port            ]
    #                    [ :battle          ]
    #                    [ :slitimem_memver ]
    #                    [ :next            ]
    attr_reader :start, :file

    def initialize(dir = nil)
      arr = find_entry_file_for_dir(dir)
      @start = arr[0]
      @file  = arr[1]
    end

    private

    def find_entry_file_for_dir(dir = nil)
      if dir.nil?
        dir = "/Users/shirokuro11/Documents/koukai_nisshi/data/json/json"
      end

      battle_datas = Hash.new
      start_arr    = Array.new

      Dir.open(dir) do |dir|
        start2_file          = nil
        port_file            = nil
        slotitem_member_file = nil
        start_file           = nil
        next_file            = nil
        ship2_file           = nil
        syutugeki_arr        = nil

        dir.sort.each do |file|
          start2_file          = dir.path + "/" + file if file =~ /_START2.json$/ # start2ファイルの抽出
          port_file            = dir.path + "/" + file if file =~ /_PORT.json$/     # portファイルの輸出
          slotitem_member_file = dir.path + "/" + file if file =~ /_SLOTITEM_MEMBER.json$/ # SLOTITEM_MEMBERの輸出
          ship2_file           = dir.path + "/" + file if file =~ /_SHIP2.json/

          if file =~ /_START.json$/
            unless syutugeki_arr.nil?
              battle_datas[start_file] = syutugeki_arr
              start_arr.push(start_file)
            end
            start_file    = dir.path + "/" + file
            syutugeki_arr = Array.new
          end

          # nextファイルからステージ情報の輸出
          if file =~ /_NEXT.json$/
            unless next_file.nil?
              syutugeki_arr.push({ :start2          => start2_file,
                                   :port            => port_file,
                                   :slotitem_member => slotitem_member_file,
                                   :next            => next_file,
                                   :ship2           => ship2_file,
                                 })
            end
            next_file = dir.path + "/" + file
          end

          # battleファイルの輸出
          if file =~ /_BATTLE.json$/
            syutugeki_arr.push({ :start2          => start2_file,
                                 :port            => port_file,
                                 :battle          => dir.path + "/" + file,
                                 :slotitem_member => slotitem_member_file,
                                 :next            => next_file,
                                 :ship2           => ship2_file,
                               })
            next_file = nil
          end

        end
      end
      return [start_arr, battle_datas]
    end
  end
end
