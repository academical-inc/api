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
        begin
          model = SectionDemand.find_by section_id: section_id
          model.add_to_set(student_ids: student_id)
          model.save!
        rescue Mongoid::Errors::DocumentNotFound
          SectionDemand.create!(section_id: section_id, student_ids: [student_id])
        end
      end

      def decr_section_demand(section_id, student_id)
        model = SectionDemand.where(section_id: section_id).first
        if not model.blank?
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
