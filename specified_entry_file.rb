# -*- coding: utf-8 -*-
## find_entry_fileから特定のステージのファイルに限定する
module Kancolle
  class SpecifiedEntryFile
    def initialize(find_entry_file = nil)
      if find_entry_file.nil?
        tes = FindEntryFile
        p tes
      end
    end
  end
end

include Kancolle
Specified_entry_file.new
