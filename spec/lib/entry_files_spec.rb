# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(__dir__)

require "spec_helper"
require "./lib/kancolle"
include Kancolle

dir = "/Users/shirokuro11/program/kancolle/test_files/json"

describe EntryFiles do
  before(:all) { @entry_files = FindEntryFile::parse_for_dir(dir) }
  # インスタンスメソッド検査
  describe 'インスタンス変数' do
    describe '.entry_files' do
      subject(:entry_files) { @entry_files.entry_files }
      it 'has 2 lengths' do
        expect(entry_files.length).to be == 2
      end
    end
  end

  # メソッド
  describe 'インスタンスメソッド' do
    describe '.extract_stage' do
      context '正常' do
        it '(5, 4) is 1 length' do
          expect(@entry_files.extract_stage(5, 4).length).to be == 1
        end
        it '(1) is 1 length' do
          expect(@entry_files.extract_stage(1).length).to be == 1
        end
      end
      context '正常でない' do
        it '(3) is not 2 length' do
          expect(@entry_files.extract_stage(3).length).not_to be == 2
        end
      end
    end
    describe '.routes' do
      subject(:routes) { @entry_files.routes }
      context '正常' do
        it 'has Array class' do
          expect(routes).to be_an_instance_of Array
        end
        it '[0] has [1,8,17,18,19]' do
          expect(routes[0]).to eq([1, 8, 17, 18, 19])
        end
      end
    end
    describe '.bauxites' do
      subject(:bauxites) { @entry_files.lost_bauxites }
      it 'has 2 length' do
        expect(bauxites.length).to be == 2
      end
      it 'has Array class' do
        expect(bauxites).to be_an_instance_of Array
      end
      it '[0] is sum 195 in Array' do
        expect(bauxites[0].inject(:+)).to be == 100
      end
      it '[1] is not sum 100 in Array' do
        expect(bauxites[1].inject(:+)).not_to be == 100
      end
    end
    describe '.names' do
      subject(:names) { @entry_files.names }
      it 'has 2 length' do
        expect(names.length).to be == 2
      end
      it 'has Array class' do
        expect(names).to be_an_instance_of Array
      end
      it '[0] is ["あきつ丸改", "扶桑改", "利根改二", "羽黒改二", "大鳳改", "瑞鶴改"]' do
        expect(names[0]).to eq ["あきつ丸改", "扶桑改", "利根改二", "羽黒改二", "大鳳改", "瑞鶴改"]
      end
      it '[1] is not ["摩耶改", "磯波", "五月雨"]' do
        expect(names[1]).not_to eq ["摩耶改", "磯波", "五月雨"]
      end
    end
    describe '.hantei' do
      subject(:hantei) { @entry_files.hantei }
      it 'has 2 length' do
        expect(hantei.length).to be == 2
      end
      it 'has Array class' do
        expect(hantei).to be_an_instance_of Array
      end
      it '[0] is ["勝利S",nil,"勝利S",nil,"勝利S"]' do
        expect(hantei[0]).to eq ["勝利S", nil, "勝利S", nil, "勝利S"]
      end
      it '[1] is not ["勝利S", "勝利B"]' do
        expect(hantei[1]).not_to eq ["勝利S", "勝利B"]
      end
    end
    describe '.day' do
      subject(:day) { @entry_files.day }
      it 'has Array class' do
        expect(day).to be_an_instance_of Array
      end
    end
  end

end
