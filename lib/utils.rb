utils = Dir[File.expand_path('../utils/**/*.rb', __FILE__)]
utils.each do |util|
  require util
end

include Academical::Utils
