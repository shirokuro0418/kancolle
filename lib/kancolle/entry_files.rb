# -*- coding: utf-8 -*-
## EntryFileの集まり

module Kancolle
  class EntryFiles
    attr_reader :entry_files

    def initialize(datas = nil)
      @entry_files = Array.new
      unless datas.nil?
        datas.each do |entry_file|
          @entry_files.push(EntryFile.new({ "start"           => entry_file.start,
                                            "file"            => entry_file.file,
                                            "start2"          => entry_file.start2,
                                            "slotitem_member" => entry_file.slotitem_member,
                                            "port"            => entry_file.port }))
        end
      end
    end
  end
end
