$LOAD_PATH.unshift(__dir__)

require 'active_support/core_ext/string/inflections'
require 'find_entry_file'

include Kancolle


Dir["#{File.expand_path('..', __FILE__)}/*.rb"].each do |file|
  filename  = File.basename file
  classname = filename.split('.rb').first.camelize
  Kancolle.autoload classname, File.expand_path("../#{filename}", __FILE__)
end
