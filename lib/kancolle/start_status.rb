# -*- coding: utf-8 -*-
## EntryFileからデータをもつクラス

module Kancolle
  class StartStatus

    attr_reader :entry_file, :names

    def initialize(entry_file = EntryFile.new)
      @entry_file = entry_file
      @names = StartStatus::names(entry_file)
    end

    private

    ##################################################################
    # クラス・メソッド                                               #
    ##################################################################
    ## 艦隊の名前を返す
    # 例 { #{start_json_file} => [ 阿武隈改, 金剛改二, 摩耶改, 熊野改, 大鳳改, 加賀改], ... }
    def StartStatus.names(entry_file)
      entry_file.startstart.each do |start_json_file|
        start = JSON::parse(start_json_file)

        start
      end
    end
    ##################################################################
    # end クラスメソッド                                             #
    ##################################################################
  end
end
