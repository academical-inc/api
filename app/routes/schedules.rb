module Academical
  module Routes
    class Schedules < Base

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

      post "/schedules" do
        schedule, code = upsert_resource
        schedule = apply_options schedule
        json_response schedule, code: code
      end

      put "/schedules/:resource_id" do
        schedule = update_resource
        schedule = apply_options schedule
        json_response schedule
      end

      include ModelRoutes

    end
  end
end



