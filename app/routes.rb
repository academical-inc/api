require 'app/routes/base'
routes = Dir[File.expand_path('../routes/**/*.rb', __FILE__)]
routes.each do |route|
  require route
end

module Academical
  class Api < Sinatra::Application

    # Include Routes
    use Routes::Main
    use Routes::Schools

  end
end

