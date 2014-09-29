require 'app/routes/base'
require 'app/routes/model_routes'
routes = Dir[File.expand_path('../routes/**/*.rb', __FILE__)]
routes.each do |route|
  require route
end

module Academical
  class Api < Sinatra::Application

    # Include Routes
    use Routes::Main
    use Routes::Schools
    use Routes::Teachers
    use Routes::Students

  end
end

