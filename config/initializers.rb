initializers = Dir[File.expand_path('../initializers/**/*.rb', __FILE__)]
initializers.each do |initer|
  require initer
end

