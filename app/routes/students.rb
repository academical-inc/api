module Academical
  module Routes
    class Students < Base

      get "/students/:resource_id/schedules" do
        inc_secs    = contains? :include_sections
        expand_secs = contains? :expand_section_events

        schedules = resource_rel :schedules
        if inc_secs
          schedules.each do |schedule|
            schedule.include_sections = true
            if expand_secs
              schedule.sections.each do |section|
                section.expand_events
              end
            end
          end
        end
        json_response schedules
      end

      include ModelRoutes

    end
  end
end


