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

      get "/students/:resource_id" do
        student = resource
        authorize! do
          is_current_student? student
        end
        json_response student
      end

      # TODO Improve this
      get "/students/:resource_id/schedules" do
        inc_secs   = contains? :include_sections
        expand_evs = contains? :expand_events

        schedules = resource_rel :schedules
        if inc_secs
          schedules.each do |schedule|
            schedule.include_sections = true
            if expand_evs
              schedule.sections.each do |section|
                section.expand_events
              end
            end
          end
        end
        if expand_evs
          schedules.each do |schedule|
            schedule.events.each do |event|
              event.expand
            end
          end
        end
        json_response schedules
      end

      post "/students" do
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
