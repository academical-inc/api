helpers = Dir[File.expand_path('../helpers/**/*.rb', __FILE__)]
helpers.each do |helper|
  require helper
end

