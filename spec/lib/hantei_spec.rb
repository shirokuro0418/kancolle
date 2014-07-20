# -*- coding: utf-8 -*-
require "spec_helper"
require "kancolle"

include Kancolle

describe "Hantei" do
  describe Kancolle do
    subject { FindEntryFile::parse_for_dir().entry_files[0] }
    its(Hantei::syouri(:file[0][:battle]){ should eq '勝利' }
    end
  end
end
