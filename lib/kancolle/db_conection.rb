require 'sqlite3'

module Kancolle
  class DbConection
    def self.all
      db = SQLite3::Database.new("./db/kancolle.db")

      fields = Array.new
      db.table_info("entry_file") do |row|
        fields << row["name"]
      end

      db.results_as_hash = true

      entry_files = Array.new
      db.execute("select * from entry_file") do |row|
        entry = Hash.new
        fields.each do |column|
          entry[column] = row[column]
        end
        entry_files.push DbEntryFile.new(entry)
      end
      return entry_files.sort{|a,b| a.date<=>b.date}
    end
  end
end
