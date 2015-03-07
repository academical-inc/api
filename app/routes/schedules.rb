module Academical
  module Routes
    class Schedules < Base

      put "/schedules/:resource_id" do
        inc_secs   = contains? :include_sections
        expand_evs = contains? :expand_events

        schedule = update_resource
        if inc_secs
          schedule.include_sections = true
          if expand_evs
            schedule.sections.each do |section|
              section.expand_events
            end
          end
        end
        if expand_evs
          schedule.personal_events.each do |personal_event|
            personal_event.expand
          end
        end
        json_response schedule
      end

      include ModelRoutes

    end
  end
end



