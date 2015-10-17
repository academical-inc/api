module Academical
  module Routes
    class Schedules < Base

      def self.model
        Schedule
      end

      # TODO Test
      def json_versioned(data, school: current_school.nickname, code: 200)
        json_response data, code: code, options: {
          version: "v#{school}".to_sym
        }
      end

      def owns_schedule?(schedule)
        is_admin? or (is_student? and schedule.student == current_student)
      end

      get "/schedules" do
        authorize! do
          is_admin?
        end

        json_versioned resources
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
          json_versioned schedule, school: schedule.school.nickname
        end
      end

      Schedule.linked_fields.each do |field|
        get "/schedules/:resource_id/#{field}" do
          schedule = resource
          authorize! do
            owns_schedule? schedule
          end

          json_versioned get_result(schedule.send(field.to_sym))
        end
      end

      # TODO Test
      post "/schedules" do
        data = extract! :data
        student_id = extract :student_id, data
        authorize! 403 do
          is_admin? or (is_student? and student_id == current_student.id.to_s)
        end

        if not is_admin?
          max_reached = current_student.schedules.latest.length == Student::MAX_SCHEDULES
          json_error 422,message: "Max number of schedules reached" if max_reached
        end
        schedule = create_resource data
        schedule.sections.each { |sec|
          incr_section_demand(sec.id.to_s, current_student.id.to_s)
        }
        json_versioned schedule, code: 201
      end

      put "/schedules/:resource_id" do
        schedule = resource
        authorize! do
          owns_schedule? schedule
        end

        update_section_demands(schedule, extract!(:data))
        updated = update_resource
        # TODO Hackish, fix and test
        # https://github.com/mongoid/mongoid/issues/3611
        updated.events.each { |ev| ev.save! }
        json_versioned updated
      end

      delete "/schedules/:resource_id" do
        schedule = resource
        authorize! do
          owns_schedule? schedule
        end

        sections = schedule.sections
        response = delete_resource
        current_student.reload
        sections.each { |sec|
          if not current_student.has_section? sec
            decr_section_demand(sec.id.to_s, current_student.id.to_s)
          end
        }
        json_response response
      end

    end
  end
end
