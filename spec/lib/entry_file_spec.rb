# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(__dir__)

require "spec_helper"
require "./lib/kancolle"
include Kancolle

dir = "/Users/shirokuro11/program/kancolle/test_files/json"

describe "EntryFile" do
  # ファイルの検査
  it "is 2014-07-20_165501.969_START.json for start_file" do
    entry_file =  FindEntryFile::parse_for_dir(dir).entry_files[0]
    expect(entry_file.start).to eq  dir + "/2014-07-20_165501.969_START.json"
  end
  it "is 2014-07-19_221912.500_START2.json for start2_file" do
    entry_file =  FindEntryFile::parse_for_dir(dir).entry_files[0]
    expect(entry_file.start2).to eq  dir + "/2014-07-19_221912.500_START2.json"
  end
  it "is 2014-07-20_165402.897_SLOTITEM_MEMBER.json for slotitem_member_file" do
    entry_file =  FindEntryFile::parse_for_dir(dir).entry_files[0]
    expect(entry_file.slotitem_member).to eq  dir + "/2014-07-20_165402.897_SLOTITEM_MEMBER.json"
  end
  it "is 2014-07-20_165455.961_PORT.json for port_file" do
    entry_file =  FindEntryFile::parse_for_dir(dir).entry_files[0]
    expect(entry_file.port).to eq  dir + "/2014-07-20_165455.961_PORT.json"
  end

  # メソッド
  it "is [5,4] for map" do
    entry_file =  FindEntryFile::parse_for_dir(dir).entry_files[0]
    expect(entry_file.map).to eq  [5, 4]
  end
  it "is [39,82,96,87,135,80] for lvs" do
    entry_file =  FindEntryFile::parse_for_dir(dir).entry_files[0]
    expect(entry_file.lvs).to eq [39,82,96,87,135,80]
  end
  it "is 100 for bauxite" do
    entry_file =  FindEntryFile::parse_for_dir(dir).entry_files[0]
    expect(entry_file.bauxite.inject(:+)).to eq  100
  end
  it "is 295 for lost_fuels" do
    entry_file =  FindEntryFile::parse_for_dir(dir).entry_files[0]
    expect(entry_file.lost_fuels.inject(:+)).to eq 295
  end
  it "is [1,8,17,18,19] for routes" do
    entry_file =  FindEntryFile::parse_for_dir(dir).entry_files[0]
    expect(entry_file.route).to eq [1, 8, 17, 18, 19]
  end
  it "is ['あきつ丸改','扶桑改','利根改二','羽黒改二','大鳳改','瑞鶴改'] for names" do
    entry_file =  FindEntryFile::parse_for_dir(dir).entry_files[0]
    expect(entry_file.names).to eq ['あきつ丸改','扶桑改','利根改二','羽黒改二','大鳳改','瑞鶴改']
  end
  it "is ['勝利S', nil, '勝利S', nil, '勝利S'] for hantei" do
    entry_file =  FindEntryFile::parse_for_dir(dir).entry_files[0]
    expect(entry_file.hantei).to eq ['勝利S',nil,'勝利S', nil,'勝利S']
  end
end
