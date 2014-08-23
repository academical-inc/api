models = Dir[File.expand_path('../models/**/*.rb', __FILE__)]
models.each do |model|
  require model
end

include Academical::Models
