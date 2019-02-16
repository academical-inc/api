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

FactoryGirl.define do

  sequence :section_id

  factory :section do
    course_name "Algebra"
    course_code "MATH1205"
    section_id
    section_number "1"
    credits 3.0
    seats {
      {
        available: 10,
        total: 25,
        taken: 15
      }
    }
    term { build(:school_term) }
    departments { build_list(:department, 2) }
    school { build(:school) }

    trait :with_events do
      events { build_list(:event, 3, :with_recurrence) }
    end

    trait :with_teachers do
      teachers { create_list(:teacher, 2, school: school) }
    end

  end
end
