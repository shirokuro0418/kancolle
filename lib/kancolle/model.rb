# -*- coding: utf-8 -*-
## モデルファイル
require 'active_support/core_ext/string/inflections'

module Kancolle
  class Model
    # @start startファイルの配列
    # @file @start[x]をkeyとした１出撃のファイル群
    # @file[@start[x]][x][ :start2          ]
    #                    [ :port            ]
    #                    [ :battle          ]
    #                    [ :slitimem_memver ]
    #                    [ :next            ]
    attr_reader :start, :file

    def initialize(start = Array.new, file = Hash.new)
      @start = start
      @file = file
    end

    private
    attr_writer :start, :file
  end
end
