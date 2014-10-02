extensions = Dir[File.expand_path('../models/extensions/**/*.rb', __FILE__)]
extensions.each do |extension|
  require extension
end

models = Dir[File.expand_path('../models/**/*.rb', __FILE__)]
models.each do |model|
  require model
end

include Academical::Models
