module Academical
  module Helpers
    module SectionDemandHelpers

      module_function

      def added_section_ids(db_schedule, new_schedule)
        new_schedule[:section_ids] - db_schedule.section_ids.map { |id| id.to_s }
      end

      def remove_section_ids(db_schedule, new_schedule)
        db_schedule.section_ids.map { |id| id.to_s } - new_schedule[:section_ids]
      end

      def incr_section_demand(section_id, student_id)
        criteria = SectionDemand.where(section_id: section_id)
        if criteria.count > 0
          model = criteria.first
          model.add_to_set(student_ids: student_id)
          model.save!
        else
          SectionDemand.create!(section_id: section_id, student_ids: [student_id])
        end

      end

      def decr_section_demand(section_id, student_id)
        criteria = SectionDemand.where(section_id: section_id)
        if criteria.count > 0
          model = criteria.first
          model.student_ids.delete(student_id)
          model.save!
        end
      end

      def update_section_demands(db_schedule, new_schedule)
        added_section_ids(db_schedule, new_schedule).each do |sec_id|
          incr_section_demand(sec_id, current_student.id.to_s)
        end
        remove_section_ids(db_schedule, new_schedule).each do |sec_id|
          decr_section_demand(sec_id, current_student.id.to_s)
        end
      end

    end
  end
end
