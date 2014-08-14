module Kancolle
  class Route
    def self.read(json)
      map = [ json[:start]["api_data"]["api_maparea_id"], json[:start]["api_data"]["api_mapinfo_no"] ]

      if map[0] == 27 && [3,4,5].include?(map[1])
        return nil
      else
        route = Array.new
        route.push(json[:start]["api_data"]["api_no"])
        tmp_file_json = json[:file].clone
        tmp_file_json.shift
        tmp_file_json.each do |t_f|
          route.push(t_f[:next]["api_data"]["api_no"])
        end
        return route
      end
    end
  end
end
