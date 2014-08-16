# -*- coding: utf-8 -*-
## DBからデータを扱うクラス

module Kancolle
  class DbEntryFile
    attr_reader :date, :ids, :map, :lvs, :lost_fuels, :lost_bulls, :lost_steels, :lost_bauxites,
                :route, :names, :slots, :hantei, :rengeki, :battle_forms,
                :seiku, :exps, :now_exps, :now_exps_end, :got_fuel, :got_bull,
                :got_steel, :got_bauxisite,
                :start, :file, :start2, :slotitem_member, :end_slotitem_member,
                :port, :end_port

    def initialize(datas = {})
      integers = [ "got_fuel","got_bull","got_steel","got_bauxisite" ]
      strings  = [ "start", "start2", "slotitem_member", "end_slotitem_member",
                   "port", "end_port"
                 ]
      arr_strings = [ "names", "slots", "hantei" ]
      datas.each do |attribute_name, value|
        if attribute_name == "date"
          @date = Time::parse(value)
        else
          next if attribute_name == "id"

          if strings.include?(attribute_name)
            eval("@#{attribute_name} = '#{value}'")
          elsif integers.include?(attribute_name)
            eval("@#{attribute_name} = #{value}")
          elsif ["file"].include?(attribute_name)
            @file = Array.new
            next if value == "[]"
            i = 0
            while data = value.slice!(/{.*?}/)
              @file[i] = eval data
              i += 1
            end
          elsif value.nil?
            eval("@#{attribute_name} = nil")
          elsif arr_strings.include?(attribute_name)
            arr = DbEntryFile.to_arrays(value)
            eval("@#{attribute_name} = #{arr}")
          else
            eval("@#{attribute_name} = #{JSON::parse value.gsub(/NULL/,'null').gsub(/nil/,'null').gsub(/{/,'[').gsub(/}/,']')}")
          end
        end
      end
    end

    ##################################################################
    # インスタンスメソッド                                           #
    ##################################################################
    public
    def to_db
      h = Hash.new
      h["date"] = @day
      self.instance_variables.each do |var|
        h[var.to_s.sub(/@/, '')] = (eval var.to_s.sub(/@/, '').to_s).to_s
      end
      h
    end

    ##################################################################
    # private                                                        #
    ##################################################################
    private
    # dbから受け取ったarrayを抜き出すメソッド
    def self.to_arrays(str)
      if str[0] != "{"
        if str != "NULL"
          return str
        else
          return nil
        end
      end
      if str == "{}"
        return []
      end
      arr = Array.new
      flg_num = 0
      new_ch = ""
      tmp_s = str.clone.strip.split(//)
      tmp_s.shift
      if tmp_s[0] == "{"
        while c = tmp_s.shift
          new_ch += c
          if c == "{"
            flg_num += 1
          end
          if c == "}"
            flg_num -= 1
          end
          if flg_num == 0
            if (tmp = tmp_s.shift) == ","
              tmp_s = tmp_s.join
              tmp_s = "{" + tmp_s
              break
            elsif tmp == "}"
              tmp_s = "{}"
              break
            else
              raise "抜き取りエラー"
            end
          end
        end
      else
        while c = tmp_s.shift
          new_ch += c
          if tmp_s[0] == "," || tmp_s[0] == "}"
            break
          end
        end
        if (tmp = tmp_s.shift) == ","
          tmp_s = tmp_s.join
          tmp_s = "{" + tmp_s
        elsif tmp == "}"
          tmp_s = nil
        else
          raise "抜き取りエラー"
        end
      end
      arr.push DbEntryFile.to_arrays(new_ch)

      while tmp_s
        flg_num = 0
        new_ch = ""
        tmp_s = tmp_s.clone.strip.split(//)
        tmp_s.shift
        if tmp_s[0] == "{"
          while c = tmp_s.shift
            new_ch += c
            if c == "{"
              flg_num += 1
            end
            if c == "}"
              flg_num -= 1
            end
            if flg_num == 0
              if (tmp = tmp_s.shift) == ","
                tmp_s = tmp_s.join
                tmp_s = "{" + tmp_s
                break
              elsif tmp == "}"
                tmp_s = nil
                break
              else
                raise "抜き取りエラー"
              end
            end
          end
        else
          while c = tmp_s.shift
            new_ch += c
            if tmp_s[0] == "," || tmp_s[0] == "}"
              break
            end
          end
          if (tmp = tmp_s.shift) == ","
            tmp_s = tmp_s.join
            tmp_s = "{" + tmp_s
          elsif tmp == "}"
            tmp_s = nil
          else
            raise "抜き取りエラー"
          end
        end

        if new_ch.nil?
          break
        else
          arr.push DbEntryFile.to_arrays(new_ch)
        end
      end
      return arr
    end
    ##################################################################
    # end インスタンスメソッド                                       #
    ##################################################################
  end
end
