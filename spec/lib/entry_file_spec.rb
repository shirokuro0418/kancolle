# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(__dir__)

require "spec_helper"
require "./lib/kancolle"
include Kancolle

dir = "/Users/shirokuro11/program/kancolle/test_files/json"

describe EntryFile do
  before(:all) { @entry_file = FindEntryFile::parse_for_dir(dir).entry_files[0] }
  # ファイルの検査
  describe 'インスタンス変数' do
    it '.start is 2014-07-20_165501.969_START.json' do
      expect(@entry_file.start).to eq  dir + "/2014-07-20_165501.969_START.json"
    end
    it ".start2 is 2014-07-19_221912.500_START2.json" do
      expect(@entry_file.start2).to eq  dir + "/2014-07-19_221912.500_START2.json"
    end
    it ".slotitem_member is 2014-07-20_165402.897_SLOTITEM_MEMBER.json" do
      expect(@entry_file.slotitem_member).to eq  dir + "/2014-07-20_165402.897_SLOTITEM_MEMBER.json"
    end
    it ".port is 2014-07-20_165455.961_PORT.json" do
      expect(@entry_file.port).to eq  dir + "/2014-07-20_165455.961_PORT.json"
    end
    it ".end_port is 2014-07-20_170023.216_PORT.json" do
      expect(@entry_file.end_port).to eq  dir + "/2014-07-20_170023.216_PORT.json"
    end
    it ".end_slotitem_member is 2014-07-20_170022.214_SLOTITEM_MEMBER.json" do
      expect(@entry_file.end_slotitem_member).to eq  dir + "/2014-07-20_170022.214_SLOTITEM_MEMBER.json"
    end
  end


  # メソッド
  describe '.map' do
    subject(:map) { @entry_file.map }
    it { expect(map).to eq([5,4]) }
  end
  describe '.lvs' do
    subject(:lvs) { @entry_file.lvs }
    it "has [39,82,96,87,135,80]" do
      expect(lvs).to eq [39,82,96,87,135,80]
    end
  end
  describe '.lost_bauxites' do
    let(:bauxites) { @entry_file.lost_bauxites }
    it "has [0,0,5,0,40,55]" do
      expect(bauxites).to eq [0, 0, 5, 0, 40, 55]
    end
    it "sum 100 for the lost bauxites" do
      expect(bauxites.inject(:+)).to eq  100
    end
  end
  describe '.lost_fuels' do
    let(:lost_fuels) { @entry_file.lost_fuels }
    it "has [35,75,39,35,60,51]" do
      expect(lost_fuels).to eq [35, 75, 39, 35, 60, 51]
    end
    it "sum 295 for lost_fuels" do
      expect(lost_fuels.inject(:+)).to eq 295
    end
  end
  describe '.lost_bulls' do
    let(:lost_bulls) {@entry_file.lost_bulls}
    it 'has [18,74,46,53,45,49]' do
      expect(lost_bulls).to eq [18, 74, 46, 53, 45, 49]
    end
    it "sum 285 for lost_bulls" do
      expect(lost_bulls.inject(:+)).to eq 285
    end
  end
  describe '.routes' do
    let(:route) {@entry_file.route}

    it "is [1,8,17,18,19] for " do
      expect(route).to eq [1, 8, 17, 18, 19]
    end
  end
  describe '.names' do
    let(:names) {@entry_file.names}

    it "has ['あきつ丸改','扶桑改','利根改二','羽黒改二','大鳳改','瑞鶴改']" do
      expect(names).to eq ['あきつ丸改','扶桑改','利根改二','羽黒改二','大鳳改','瑞鶴改']
    end
  end
  describe '.hantei' do
    let(:hantei) {@entry_file.hantei}

    it "has ['勝利S', nil, '勝利S', nil, '勝利S']" do
      expect(hantei).to eq ['勝利S',nil,'勝利S', nil,'勝利S']
    end
  end
  describe '.slots' do
    subject(:slots) {@entry_file.slots}

    it "はArrayである" do
      expect(slots).to be_an_instance_of Array
    end
    it "は６つからなる" do
      expect(slots.length).to eq 6
    end
  end
  describe '.hougeki1' do
    subject(:hougeki1) {@entry_file.hougeki1}

    it 'はArrayである' do
      expect(hougeki1).to be_an_instance_of Array
    end
    it 'は５つからなる' do
      expect(hougeki1.length).to eq 5
    end
  end
  describe '.hougeki2' do
    subject(:hougeki1) {@entry_file.hougeki1}

    it 'はArrayである' do
      expect(hougeki1).to be_an_instance_of Array
    end
    it 'は５つからなる' do
      expect(hougeki1.length).to eq 5
    end
  end
  describe '.rengeki' do
    subject(:rengeki) {@entry_file.rengeki}

    it 'はArrayである' do
      expect(rengeki).to be_an_instance_of Array
    end
    it 'は６つからなる' do
      expect(rengeki.length).to eq 6
    end
  end
  describe '.battle_forms' do
    subject(:battle_forms) {@entry_file.battle_forms}

    it 'はArrayである' do
      expect(battle_forms).to be_an_instance_of Array
    end
    it 'は５つからなる' do
      expect(battle_forms.length).to eq 5
    end
  end
  describe '.seiku' do
    subject(:seiku) {@entry_file.seiku}

    it 'はArrayである' do
      expect(seiku).to be_an_instance_of Array
    end
    it 'は５つからなる' do
      expect(seiku.length).to eq 5
    end
  end


end
