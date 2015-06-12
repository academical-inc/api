module Academical
  module Routes
    class Schedules < Base

      def self.model
        Schedule
      end

      def owns_schedule?(schedule)
        is_admin? or (is_student? and schedule.student == current_student)
      end

      def apply_options(schedule)
        inc_secs   = contains? :include_sections
        expand_evs = contains? :expand_events

        if inc_secs
          schedule.include_sections = true
          if expand_evs
            schedule.sections.each do |section|
              section.expand_events
            end
          end
        end
        if expand_evs
          schedule.events.each do |event|
            event.expand
          end
        end
        schedule
      end

      get "/schedules" do
        authorize! do
          is_admin?
        end

        json_response resources
      end

      get "/schedules/:resource_id" do
        schedule = resource
        authorize! do
          if schedule.public == true
            true
          else
            owns_schedule? schedule
          end
        end

        format = extract :format
        if format == 'ics'
          json_response schedule.to_ical
        else
          schedule = apply_options schedule
          json_response schedule
        end
      end

      Schedule.linked_fields.each do |field|
        get "/schedules/:resource_id/#{field}" do
          schedule = resource
          authorize! do
            owns_schedule? schedule
          end

          json_response get_result(schedule.send(field.to_sym))
        end
      end

      post "/schedules" do
        data = extract! :data
        student_id = extract :student_id, data
        authorize! 403 do
          is_admin? or (is_student? and student_id == current_student.id.to_s)
        end

        schedule = create_resource data
        schedule = apply_options schedule
        json_response schedule, code: 201
      end

      put "/schedules/:resource_id" do
        schedule = resource
        authorize! do
          owns_schedule? schedule
        end

        schedule = update_resource
        schedule = apply_options schedule
        json_response schedule
      end

      delete "/schedules/:resource_id" do
        schedule = resource
        authorize! do
          owns_schedule? schedule
        end

        json_response delete_resource
      end

    end
  end
end



