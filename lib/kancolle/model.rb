# -*- coding: utf-8 -*-
## モデルファイル
require 'active_support/core_ext/string/inflections'

module Kancolle
  class Model
    # @start startファイルの配列
    # @file @start[x]をkeyとした１出撃のファイル群
    # @file[@start[x]][x][ :ship2           ]
    #                    [ :battle          ]
    #                    [ :next            ]
    #                    [ :battle_result   ]
    # @start2          @start[x]をkeyとしたSTART2.jsonのファイルパス
    # @slotitem_member 〃                  SLOTITEM_BEMBER.jsonのファイルパス
    attr_reader :start, :file, :start2, :slotitem_member, :port

    def initialize
      @start           = Array.new
      @file            = Hash.new
      @start2          = Hash.new
      @slotitem_member = Hash.new
      @port            = Hash.new
    end

    def initialize datas = {}
      datas.each do |attribute_name, value|
        send "#{attribute_name.to_s.underscore}=", value
      end
    end

    private
    attr_writer :start, :file, :start2, :slotitem_member, :port
  end
end
