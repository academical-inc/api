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

module Academical
  module Routes
    class Students < Base

      def is_current_student?(student)
        is_admin? or (is_student? and student == current_student)
      end

      before "/students*" do
        if request.delete? or request.put? or (request.get? and request.path_info == "/students")
          authorize! do
            is_admin?
          end
        end
      end

      Student.linked_fields.each do |field|
        before "/students/:resource_id/#{field}" do
          authorize! do
            is_current_student? resource
          end
        end
      end

      get "/students/:resource_id/?" do
        student = resource
        authorize! do
          is_current_student? student
        end
        json_response student
      end

      # TODO Improve this
      # TODO Test
      get "/students/:resource_id/schedules/?" do
        schedules = resource.schedules.latest
        json_response schedules, options: {
          version: "v#{current_school.nickname}".to_sym
        }
      end

      post "/students/?" do
        data = extract! :data
        id            = extract :id, data
        auth0_user_id = extract :auth0_user_id, data

        student = Student.any_of(
          {id: id},
          {auth0_user_id: auth0_user_id}
        ).first

        if student.blank?
          authorize! 403 do
            is_admin? or is_student?
          end
          json_response create_resource(data), code: 201
        else
          authorize! 403 do
            is_current_student? student
          end
          student.update_attributes! data
          json_response student
        end
      end

      include ModelRoutes

    end
  end
end
