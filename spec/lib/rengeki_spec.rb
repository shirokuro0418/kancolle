# -*- coding: utf-8 -*-
require "spec_helper"
require "./lib/kancolle"
include Kancolle

dir = "/Users/shirokuro11/program/kancolle/test_files/json"

describe Rengeki do
  before(:all){
    ### 通常海域のjsonデータ
    start2              = nil
    slotitem_member     = nil
    port                = nil
    start               = nil
    end_slotitem_member = nil
    end_port            = nil
    open("#{dir}/2014-07-19_221912.500_START2.json"){|f| start2 = JSON::parse(f.read)}
    open("#{dir}/2014-07-20_165402.897_SLOTITEM_MEMBER.json"){|f| slotitem_member = JSON::parse(f.read)}
    open("#{dir}/2014-07-20_165455.961_PORT.json"){|f| port = JSON::parse(f.read)}
    open("#{dir}/2014-07-20_165501.969_START.json"){|f| start = JSON::parse(f.read)}
    open("#{dir}/2014-07-20_170022.214_SLOTITEM_MEMBER.json"){|f| end_slotitem_member = JSON::parse(f.read)}
    open("#{dir}/2014-07-20_170023.216_PORT.json"){|f| end_port = JSON::parse(f.read)}
    file = Array.new
    h = Hash.new
    open("#{dir}/2014-07-20_165517.978_BATTLE.json"){|f| h[:battle] = JSON::parse(f.read)}
    open("#{dir}/2014-07-20_165605.007_BATTLE_RESULT.json"){|f| h[:battle_result] = JSON::parse(f.read)}
    open("#{dir}/2014-07-20_165619.016_SHIP2.json"){|f| h[:ship2] = JSON::parse(f.read)}
    file[0] = h
    h = Hash.new
    open("#{dir}/2014-07-20_165619.020_NEXT.json"){|f| h[:next] = JSON::parse(f.read)}
    file[1] = h
    h = Hash.new
    open("#{dir}/2014-07-20_165632.028_NEXT.json"){|f| h[:next] = JSON::parse(f.read)}
    open("#{dir}/2014-07-20_165641.034_BATTLE.json"){|f| h[:battle] = JSON::parse(f.read)}
    open("#{dir}/2014-07-20_165750.073_BATTLE_RESULT.json"){|f| h[:battle_result] = JSON::parse(f.read)}
    open("#{dir}/2014-07-20_165804.085_SHIP2.json"){|f| h[:ship2] = JSON::parse(f.read)}
    file[2] = h
    h = Hash.new
    open("#{dir}/2014-07-20_165804.090_NEXT.json"){|f| h[:next] = JSON::parse(f.read)}
    file[3] = h
    h = Hash.new
    open("#{dir}/2014-07-20_165815.096_NEXT.json"){|f| h[:next] = JSON::parse(f.read)}
    open("#{dir}/2014-07-20_165827.106_BATTLE.json"){|f| h[:battle] = JSON::parse(f.read)}
    open("#{dir}/2014-07-20_165945.151_BATTLE_MIDNIGHT.json"){|f| h[:battle_midnight] = JSON::parse(f.read)}
    open("#{dir}/2014-07-20_170002.160_BATTLE_RESULT.json"){|f| h[:battle_result] = JSON::parse(f.read)}
    file[4] = h
    @json_defult = {
      :start2              => start2,
      :slotitem_member     => slotitem_member,
      :port                => port,
      :start               => start,
      :ent_slotitem_member => end_slotitem_member,
      :end_port            => end_port,
      :file                => file
    }
    ###### ここまで ########

    ###### 夏イベの時のjsonデータ
    start2              = nil
    slotitem_member     = nil
    port                = nil
    start               = nil
    end_slotitem_member = nil
    end_port            = nil
    open("#{dir}/2014-08-14_130735.526_START2.json"){|f| start2 = JSON::parse(f.read)}
    open("#{dir}/2014-08-14_134425.318_SLOTITEM_MEMBER.json"){|f| slotitem_member = JSON::parse(f.read)}
    open("#{dir}/2014-08-14_143336.024_PORT.json"){|f| port = JSON::parse(f.read)}
    open("#{dir}/2014-08-14_143346.033_START.json"){|f| start = JSON::parse(f.read)}
    open("#{dir}/2014-08-14_144105.384_SLOTITEM_MEMBER.json"){|f| end_slotitem_member = JSON::parse(f.read)}
    open("#{dir}/2014-08-14_144106.386_PORT.json"){|f| end_port = JSON::parse(f.read)}
    @json_summer = {
      :start2              => start2,
      :slotitem_member     => slotitem_member,
      :port                => port,
      :start               => start,
      :ent_slotitem_member => end_slotitem_member,
      :end_port            => end_port,
      :file                => nil
    }
  }
  describe '.read(json) at defult' do
    subject(:read){Rengeki.read(@json_defult)}
    it 'return is [ 0,3,2,3,0,0 ]' do
      expect(read).to eq [ 0,3,2,3,0,0 ]
    end
    it 'return のlengthは6' do
      expect(read.length).to be 6
    end
  end
  describe 'read(json) at 2014 summer' do
    subject(:read){Rengeki.read(@json_summer)}
    it 'return is nil' do
      expect(read).to eq nil
    end
  end
end
