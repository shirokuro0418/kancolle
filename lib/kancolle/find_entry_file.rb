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
    def self.parse_for_dir(d = nil)
      if d.nil?
        d = "/Users/shirokuro11/Documents/koukai_nisshi/data/json/json"
      end
      entryfiles           = Array.new

      Dir.open(d) do |dir|
        start2_file            = nil
        port_file              = nil
        slotitem_member_file   = nil
        next_file              = nil
        ship2_file             = nil
        battle_file            = nil
        battle_midnight_file   = nil
        syutugeki_arr          = nil
        e_start_file           = nil
        e_start2_file          = nil
        e_slotitem_member_file = nil
        e_port_file            = nil

        dir.sort.each do |file|
          start2_file          = dir.path.sub(/[^\/]$/, '\&/') + file if file =~ /_START2.json$/ # start2ファイルの抽出
          port_file            = dir.path.sub(/[^\/]$/, '\&/') + file if file =~ /_PORT.json$/     # portファイルの輸出
          # SLOTITEM_MEMBERの輸出
          slotitem_member_file = dir.path.sub(/[^\/]$/, '\&/') + file if file =~ /_SLOTITEM_MEMBER.json$/
          ship2_file           = dir.path.sub(/[^\/]$/, '\&/') + file if file =~ /_SHIP2.json$/
          battle_file          = dir.path.sub(/[^\/]$/, '\&/') + file if file =~ /_BATTLE.json$/
          battle_midnight_file = dir.path.sub(/[^\/]$/, '\&/') + file if file =~ /_BATTLE_MIDNIGHT.json$/

          if file =~ /_START.json$/
            unless syutugeki_arr.nil?
              entryfiles.push(EntryFile.new({ "start"           => e_start_file,
                                              "file"            => syutugeki_arr,
                                              "start2"          => e_start2_file,
                                              "slotitem_member" => e_slotitem_member_file,
                                              "port"            => e_port_file }))
            end
            e_start_file           = dir.path.sub(/[^\/]$/, '\&/') + file
            e_start2_file          = start2_file
            e_slotitem_member_file = slotitem_member_file
            e_port_file            = port_file
            syutugeki_arr          = Array.new
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
            next_file = dir.path.sub(/[^\/]$/, '\&/') + file
          end

          # battleファイルの輸出
          if file =~ /_BATTLE_RESULT.json$/
            syutugeki_arr.push({ :battle          => battle_file,
                                 :battle_result   => dir.path.sub(/[^\/]$/, '\&/') + file,
                                 :next            => next_file,
                                 :ship2           => ship2_file,
                                 :battle_midnight => battle_midnight_file
                               })
            battle_file          = nil
            next_file            = nil
            ship2_file           = nil
            battle_midnight_file = nil
          end
        end
        unless syutugeki_arr.nil?
          entryfiles.push(EntryFile.new({ "start"           => e_start_file,
                                          "file"            => syutugeki_arr,
                                          "start2"          => e_start2_file,
                                          "slotitem_member" => e_slotitem_member_file,
                                          "port"            => e_port_file }))
        end
      end
      return EntryFiles.new(entryfiles)
    end
  end
end
