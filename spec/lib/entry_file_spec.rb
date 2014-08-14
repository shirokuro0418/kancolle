# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(__dir__)

require "spec_helper"
require "./lib/kancolle"
include Kancolle

dir = "/Users/shirokuro11/program/kancolle/test_files/json"

describe EntryFile do
  before(:all){
    ### 通常海域のjsonデータ
    start2              = "#{dir}/2014-07-19_221912.500_START2.json"
    slotitem_member     = "#{dir}/2014-07-20_165402.897_SLOTITEM_MEMBER.json"
    port                = "#{dir}/2014-07-20_165455.961_PORT.json"
    start               = "#{dir}/2014-07-20_165501.969_START.json"
    end_slotitem_member = "#{dir}/2014-07-20_170022.214_SLOTITEM_MEMBER.json"
    end_port            = "#{dir}/2014-07-20_170023.216_PORT.json"
    file = Array.new
    h = Hash.new
    h[:battle]        = "#{dir}/2014-07-20_165517.978_BATTLE.json"
    h[:battle_result] = "#{dir}/2014-07-20_165605.007_BATTLE_RESULT.json"
    h[:ship2]         = "#{dir}/2014-07-20_165619.016_SHIP2.json"
    file[0] = h
    h = Hash.new
    h[:next] = "#{dir}/2014-07-20_165619.020_NEXT.json"
    file[1] = h
    h = Hash.new
    h[:next]          = "#{dir}/2014-07-20_165632.028_NEXT.json"
    h[:battle]        = "#{dir}/2014-07-20_165641.034_BATTLE.json"
    h[:battle_result] = "#{dir}/2014-07-20_165750.073_BATTLE_RESULT.json"
    h[:ship2]         = "#{dir}/2014-07-20_165804.085_SHIP2.json"
    file[2] = h
    h = Hash.new
    h[:next] = "#{dir}/2014-07-20_165804.090_NEXT.json"
    file[3] = h
    h = Hash.new
    h[:next]            = "#{dir}/2014-07-20_165815.096_NEXT.json"
    h[:battle]          = "#{dir}/2014-07-20_165827.106_BATTLE.json"
    h[:battle_midnight] = "#{dir}/2014-07-20_165945.151_BATTLE_MIDNIGHT.json"
    h[:battle_result]   = "#{dir}/2014-07-20_170002.160_BATTLE_RESULT.json"
    file[4] = h
    @datas_defult = {
      :start2              => start2,
      :slotitem_member     => slotitem_member,
      :port                => port,
      :start               => start,
      :end_slotitem_member => end_slotitem_member,
      :end_port            => end_port,
      :file                => file
    }
    ###### ここまで ########

    ###### 夏イベの時のjsonデータ
    start2              = "#{dir}/2014-08-14_130735.526_START2.json"
    slotitem_member     = "#{dir}/2014-08-14_134425.318_SLOTITEM_MEMBER.json"
    port                = "#{dir}/2014-08-14_143336.024_PORT.json"
    start               = "#{dir}/2014-08-14_143346.033_START.json"
    end_slotitem_member = "#{dir}/2014-08-14_144105.384_SLOTITEM_MEMBER.json"
    end_port            = "#{dir}/2014-08-14_144106.386_PORT.json"
    @datas_summer = {
      :start2              => start2,
      :slotitem_member     => slotitem_member,
      :port                => port,
      :start               => start,
      :end_slotitem_member => end_slotitem_member,
      :end_port            => end_port,
      :file                => nil
    }
  }
  before(:each) {
    @defult = EntryFile.new(@datas_defult)
    @summer = EntryFile.new(@datas_summer)
  }
  describe '通常ステージ' do
    describe 'インスタンス変数' do
      it ".start" do
        expect(@defult.start).not_to be_nil
        expect(@defult.start).to eq @datas_defult[:start]
      end
      it ".file" do
        expect(@defult.file).not_to be_nil
        expect(@defult.file).to eq @datas_defult[:file]
      end
      it ".start2" do
        expect(@defult.start2).not_to be_nil
        expect(@defult.start2).to eq @datas_defult[:start2]
      end
      it ".slotitem_member" do
        expect(@defult.slotitem_member).not_to be_nil
        expect(@defult.slotitem_member).to eq @datas_defult[:slotitem_member]
      end
      it ".end_slotitem_member" do
        expect(@defult.end_slotitem_member).not_to be_nil
        expect(@defult.end_slotitem_member).to eq @datas_defult[:end_slotitem_member]
      end
      it ".port" do
        expect(@defult.port).not_to be_nil
        expect(@defult.port).to eq @datas_defult[:port]
      end
      it ".end_port" do
        expect(@defult.end_port).not_to be_nil
        expect(@defult.end_port).to eq @datas_defult[:end_port]
      end
    end
    describe 'メソッド' do
      it ".ids は [12136, 421, 452, 35, 12110, 12662]" do
        expect(@defult.ids).not_to be_nil
        expect(@defult.ids).to eq [12136, 421, 452, 35, 12110, 12662]
      end
      it ".map は [5,4]" do
        expect(@defult.map).not_to be_nil
        expect(@defult.map).to eq [5,4]
      end
      it ".lvs は [39,82,96,87,135,80]" do
        expect(@defult.lvs).not_to be_nil
        expect(@defult.lvs).to eq [39,82,96,87,135,80]
      end
      it ".lost_fuels の合計値は 295" do
        expect(@defult.lost_fuels.inject(:+)).not_to be_nil
        expect(@defult.lost_fuels.inject(:+)).to eq 379
      end
      it ".lost_bulls の合計値は 285" do
        expect(@defult.lost_bulls).not_to be_nil
        expect(@defult.lost_bulls.inject(:+)).to eq 285
      end
      it ".lost_steel は 158" do
        expect(@defult.lost_steel.inject(:+)).not_to be_nil
        expect(@defult.lost_steel.inject(:+)).to eq 158
      end
      it ".lost_bauxisite は 100" do
        expect(@defult.lost_bauxites.inject(:+)).not_to be_nil
        expect(@defult.lost_bauxites.inject(:+)).to eq 100
      end
      it ".route は [1,8,17,18,19]" do
        expect(@defult.route).not_to be_nil
        expect(@defult.route).to eq [1,8,17,18,19]
      end
      it ".names は ['あきつ丸改','扶桑改','利根改','羽黒改','大鳳改','瑞鶴改']" do
        expect(@defult.names).not_to be_nil
        expect(@defult.names).to eq ['あきつ丸改','扶桑改','利根改二','羽黒改二','大鳳改','瑞鶴改']
      end
      it ".slots[0] は ['ドラム缶(輸送用)', 'ドラム缶(輸送用)', 'ドラム缶(輸送用)', nil, nil]" do
        expect(@defult.slots[0]).not_to be_nil
        expect(@defult.slots[0]).to eq ['ドラム缶(輸送用)', 'ドラム缶(輸送用)', 'ドラム缶(輸送用)', nil, nil]
      end
      it ".slots[1] は ['46cm三連装砲', '46cm三連装砲', '46cm三連装砲', '零式水上観測機', nil]" do
        expect(@defult.slots[1]).not_to be_nil
        expect(@defult.slots[1]).to eq ['46cm三連装砲', '46cm三連装砲', '46cm三連装砲', '零式水上観測機', nil]
      end
      it ".slots[2] は ['20.3cm(3号)連装砲', '20.3cm(3号)連装砲', '瑞雲12型', 'ドラム缶(輸送用)', nil]" do
        expect(@defult.slots[2]).not_to be_nil
        expect(@defult.slots[2]).to eq ['20.3cm(3号)連装砲', '20.3cm(3号)連装砲', '瑞雲12型', 'ドラム缶(輸送用)', nil]
      end
      it ".slots[3] は ['20.3cm(2号)連装砲', '20.3cm(2号)連装砲', '零式水上観測機', '32号対水上電探', nil]" do
        expect(@defult.slots[3]).not_to be_nil
        expect(@defult.slots[3]).to eq ['20.3cm(2号)連装砲', '20.3cm(2号)連装砲', '零式水上観測機', '32号対水上電探', nil]
      end
      it ".slots[4] は ['烈風改', '32号対水上電探', '15.5cm三連装副砲', '零式艦戦62型(爆戦)', nil]" do
        expect(@defult.slots[4]).not_to be_nil
        expect(@defult.slots[4]).to eq ['烈風改', '32号対水上電探', '15.5cm三連装副砲', '零式艦戦62型(爆戦)', nil]
      end
      it ".slots[5] は ['烈風', '烈風', '15.5cm三連装副砲', '天山一二型(友永隊)', nil]" do
        expect(@defult.slots[5]).not_to be_nil
        expect(@defult.slots[5]).to eq ['烈風', '烈風', '15.5cm三連装副砲', '天山一二型(友永隊)', nil]
      end
      it ".hantei は ['S', nil, 'S', nil, 'S']" do
        expect(@defult.hantei).not_to be_nil
        expect(@defult.hantei).to eq ["S", nil, "S", nil, "S"]
      end
      it ".rengeki は [0,3,2,3,0,0]" do
        expect(@defult.rengeki).not_to be_nil
        expect(@defult.rengeki).to eq [0, 3, 2, 3, 0, 0]
      end
      it ".battle_forms は ['T字不利',nil,'同行戦',nil,'同行戦']" do
        expect(@defult.battle_forms).not_to be_nil
        expect(@defult.battle_forms).to eq ['T字不利',nil,'同行戦',nil,'同行戦']
      end
      it ".seiku は ['制空権確保',nil,'航空優勢',nil,'制空権確保']" do
        expect(@defult.seiku).not_to be_nil
        expect(@defult.seiku).to eq ['制空権確保',nil,'航空優勢',nil,'制空権確保']
      end
      it ".exps は [2268, 3024, 1512, 1512, 1512, 1512]" do
        expect(@defult.exps).not_to be_nil
        expect(@defult.exps).to eq [2268, 3024, 1512, 1512, 1512, 1512]
      end
      it ".now_exps は [77194, 423113, 716481, 503148, 2293154, 393049]" do
        expect(@defult.now_exps).not_to be_nil
        expect(@defult.now_exps).to eq [77194, 423113, 716481, 503148, 2293154, 393049]
      end
      it ".now_exps_end は [79462, 426137, 717993, 504660, 2294666, 394561]" do
        expect(@defult.now_exps_end).not_to be_nil
        expect(@defult.now_exps_end).to eq [79462, 426137, 717993, 504660, 2294666, 394561]
      end
      it ".got_fuel は 115" do
        expect(@defult.got_fuel).not_to be_nil
        expect(@defult.got_fuel).to eq 115
      end
      it ".got_bull は 115" do
        expect(@defult.got_bull).not_to be_nil
        expect(@defult.got_bull).to eq 0
      end
      it ".got_steel は 115" do
        expect(@defult.got_steel).not_to be_nil
        expect(@defult.got_steel).to eq 0
      end
      it ".got_bauxisite は 115" do
        expect(@defult.got_bauxisite).not_to be_nil
        expect(@defult.got_bauxisite).to eq 0
      end
    end
  end

  describe '夏イベステージ' do
    describe 'インスタンス変数' do
      it ".start" do
        expect(EntryFile.new(@datas_summer).start).not_to be_nil
        expect(EntryFile.new(@datas_summer).start).to eq @datas_summer[:start]
      end
      it ".file" do
        expect(EntryFile.new(@datas_summer).file).to be_nil
      end
      it ".start2" do
        expect(EntryFile.new(@datas_summer).start2).not_to be_nil
        expect(EntryFile.new(@datas_summer).start2).to eq @datas_summer[:start2]
      end
      it ".slotitem_member" do
        expect(EntryFile.new(@datas_summer).slotitem_member).not_to be_nil
        expect(EntryFile.new(@datas_summer).slotitem_member).to eq @datas_summer[:slotitem_member]
      end
      it ".end_slotitem_member" do
        expect(EntryFile.new(@datas_summer).end_slotitem_member).not_to be_nil
        expect(EntryFile.new(@datas_summer).end_slotitem_member).to eq @datas_summer[:end_slotitem_member]
      end
      it ".port" do
        expect(EntryFile.new(@datas_summer).port).not_to be_nil
        expect(EntryFile.new(@datas_summer).port).to eq @datas_summer[:port]
      end
      it ".end_port" do
        expect(EntryFile.new(@datas_summer).end_port).not_to be_nil
        expect(EntryFile.new(@datas_summer).end_port).to eq @datas_summer[:end_port]
      end
    end
    describe 'メソッド' do
      it ".ids は [30797,1949,30048,12136,460,840]" do
        expect(@summer.ids).not_to be_nil
        expect(@summer.ids).to eq [30797,1949,30048,12136,460,840]
      end
      it ".map は [27,4]" do
        expect(@summer.map).not_to be_nil
        expect(@summer.map).to eq [27,4]
      end
      it ".lvs は [15,91,54,68,134,78]" do
        expect(@summer.lvs).not_to be_nil
        expect(@summer.lvs).to eq [15,91,54,68,134,78]
      end
      it ".lost_fuels の合計値は 302" do
        expect(@summer.lost_fuels.inject(:+)).not_to be_nil
        expect(@summer.lost_fuels.inject(:+)).not_to eq 302
      end
      it ".lost_bulls の合計値は 266" do
        expect(@summer.lost_bulls).not_to be_nil
        expect(@summer.lost_bulls.inject(:+)).to eq 266
      end
      it ".lost_steel の合計値は 300" do
        expect(@summer.lost_steel.inject(:+)).not_to be_nil
        expect(@summer.lost_steel.inject(:+)).to eq 300
      end
      it ".lost_bauxites の合計値は 520" do
        expect(@summer.lost_bauxites.inject(:+)).not_to be_nil
        expect(@summer.lost_bauxites.inject(:+)).to eq 520
      end
      it ".route は nil" do
        expect(@summer.route).to be_nil
      end
      it ".names は ['飛龍','蒼龍改二','雲龍改','あきつ丸改','加賀改','日向改']" do
        expect(@summer.names).not_to be_nil
        expect(@summer.names).to eq ['飛龍','蒼龍改二','雲龍改','あきつ丸改','加賀改','日向改']
      end
      it ".slots[0] は ['流星改', '烈風', '烈風', '彩雲', nil]" do
        expect(@summer.slots[0]).not_to be_nil
        expect(@summer.slots[0]).to eq ['流星改', '烈風', '烈風', '彩雲', nil]
      end
      it ".slots[1] は ['流星改', '烈風(六〇一空)', '烈風', '彩雲', nil]" do
        expect(@summer.slots[1]).not_to be_nil
        expect(@summer.slots[1]).to eq ['流星改', '烈風(六〇一空)', '烈風', '彩雲', nil]
      end
      it ".slots[2] は ['流星改', '烈風', '烈風', '彩雲', nil]" do
        expect(@summer.slots[2]).not_to be_nil
        expect(@summer.slots[2]).to eq ['流星改', '烈風', '烈風', '彩雲', nil]
      end
      it ".slots[3] は ['烈風', '烈風', '零式艦戦21型(熟練)', nil, nil]" do
        expect(@summer.slots[3]).not_to be_nil
        expect(@summer.slots[3]).to eq ['烈風', '烈風', '零式艦戦21型(熟練)', nil, nil]
      end
      it ".slots[4] は ['烈風', '流星改', '烈風改', '彩雲', nil]" do
        expect(@summer.slots[4]).not_to be_nil
        expect(@summer.slots[4]).to eq ['烈風', '流星改', '烈風改', '彩雲', nil]
      end
      it ".slots[5] は ['46cm三連装砲', '46cm三連装砲', '零式水上観測機', '三式弾', nil]" do
        expect(@summer.slots[5]).not_to be_nil
        expect(@summer.slots[5]).to eq ['46cm三連装砲', '46cm三連装砲', '零式水上観測機', '三式弾', nil]
      end
      it ".hantei は nil" do
        expect(@summer.hantei).to be_nil
      end
      it ".rengeki は nil" do
        expect(@summer.rengeki).to be_nil
      end
      it ".battle_forms は nil" do
        expect(@summer.battle_forms).to be_nil
      end
      it ".seiku は nil" do
        expect(@summer.seiku).to be_nil
      end
      it ".exps は [3150, 1050, 1050, 1050, 1050, 1050]" do
        expect(@summer.exps).not_to be_nil
        expect(@summer.exps).to eq [3150, 1050, 1050, 1050, 1050, 1050]
      end
      it ".now_exps は [10725, 567703, 147460, 248288, 2205731, 360230]" do
        expect(@summer.now_exps).not_to be_nil
        expect(@summer.now_exps).to eq [10725, 567703, 147460, 248288, 2205731, 360230]
      end
      it ".now_exps_end は [13875, 568753, 148510, 249338, 2206781, 361280]" do
        expect(@summer.now_exps_end).not_to be_nil
        expect(@summer.now_exps_end).to eq [13875, 568753, 148510, 249338, 2206781, 361280]
      end
      it ".got_fuel は 0" do
        expect(@summer.got_fuel).not_to be_nil
        expect(@summer.got_fuel).to be 0
      end
      it ".got_bull は 0" do
        expect(@summer.got_bull).not_to be_nil
        expect(@summer.got_bull).to be 0
      end
      it ".got_steel は 0" do
        expect(@summer.got_steel).not_to be_nil
        expect(@summer.got_steel).to be 0
      end
      it ".got_bauxisite は 0" do
        expect(@summer.got_bauxisite).not_to be_nil
        expect(@summer.got_bauxisite).to be 0
      end
    end
  end
end
