# -*- coding: utf-8 -*-
## モデルから自由に変更可能クラス

module Kancolle
  class EntryFile < Kancolle::Model

    ##################################################################
    # イニシャライズ                                                 #
    ##################################################################
    # def initialize(start = Array.new, file = Hash.new, start2 = Hash.new, slotitem_member = Hash.new)
    #   @start           = start
    #   @file            = file
    #   @start2          = start2
    #   @slotitem_member = slotitem_member

      
    # end
    ##################################################################
    # インスタンスメソッド                                           #
    ##################################################################

    ##################################################################
    # end インスタンスメソッド                                       #
    ##################################################################

    private
    ## 艦隊の名前を返す
    # 例 { #{start_json_file} => [ 阿武隈改, 金剛改二, 摩耶改, 熊野改, 大鳳改, 加賀改], ... }
    # def names
    #   @start.each do |start_json_file|
    #     start = JSON::parse(start_json_file)

    #     start
    #   end
    # end
  end
end
