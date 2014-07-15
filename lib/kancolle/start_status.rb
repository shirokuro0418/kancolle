# -*- coding: utf-8 -*-
## EntryFileからデータをもつクラス

module Kancolle
  class StartStatus < EntryFile

    attr_reader :entry_file, :names

    def initialize(datas = nil)
      super(datas)

      @names = StartStatus::names(EntryFile.new(datas))
    end

    ##################################################################
    # クラス・メソッド                                               #
    ##################################################################
    def StartStatus.parse(datas)
      StartStatus.new(datas)
    end
    ##################################################################
    # end クラスメソッド                                             #
    ##################################################################

    private

    ##################################################################
    # クラス・メソッド                                               #
    ##################################################################
    ## 艦隊の名前を返す
    # 例 { #{start_json_file} => [ 阿武隈改, 金剛改二, 摩耶改, 熊野改, 大鳳改, 加賀改], ... }
    def StartStatus.names(entry_file)
      names = Hash.new
      entry_file.start.each do |start_file|
        kantai_names = Array.new.map{nil}

        ## portファイルから艦隊のsortno 共通の艦娘のID取得
        open(entry_file.port[start_file]) do |j|
          port = JSON::parse(j.read)

          port["api_data"]["api_deck_port"][0]["api_ship"].each_with_index do |kantai, i|
            port["api_data"]["api_ship"].each do |kanmusu|
              if kanmusu["api_id"] == kantai
                kantai_names[i] = kanmusu["api_sortno"]
              end
            end
          end
        end
        ## start2ファイルから艦娘の名前を取得
        tmp_kantai_names = kantai_names
        open(entry_file.start2[start_file]) do |j|
          start2 = JSON::parse(j.read)

          start2["api_data"]["api_mst_ship"].each do |kanmusu|
            tmp_kantai_names.each_with_index do |kantai, i|
              kantai_names[i] = kanmusu["api_name"] if kanmusu["api_sortno"] == kantai
            end
          end
        end
        names[start_file] = kantai_names
      end
      return names
    end
    ##################################################################
    # end クラスメソッド                                             #
    ##################################################################
  end
end
