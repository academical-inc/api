#
# Copyright (C) 2012-2019 Academical Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

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

