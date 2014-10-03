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
    use Routes::Sections
    use Routes::Schedules

    # Re raise Sinatra::NotFound to be caught inside Routes
    not_found do
      raise env['sinatra.error']
    end

  end
end

