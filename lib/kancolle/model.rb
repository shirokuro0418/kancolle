# -*- coding: utf-8 -*-
## モデルファイル
require 'active_support/core_ext/string/inflections'

module Kancolle
  class Model
    # @start startファイルの配列
    # @file @start[x]をkeyとした１出撃のファイル群
    # @file[@start[x]][x][ :port            ]
    #                    [ :battle          ]
    #                    [ :next            ]
    attr_reader :start, :file, :start2, :slotitem_member

    def initialize
      @start           = Array.new
      @file            = Hash.new
      @start2          = Hash.new
      @slotitem_member = Hash.new
    end


    def initialize datas = {}  # (start = Array.new, file = Hash.new, start2 = Hash.new, slotitem_member = Hash.new)
      datas.each do |attribute_name, value|
        send "#{attribute_name.to_s.underscore}=", value
      end
    end

    private
    attr_writer :start, :file, :start2, :slotitem_member
  end
end
