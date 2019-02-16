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

  factory :schedule do
    name "My first schedule"
    total_credits 6.0
    total_sections 2
    term { build(:school_term) }
    student { build(:student) }
    school { student.school }
    events { build_list(:event, 2, :with_recurrence) }
    sections { build_list(:section, 2, :with_events) }
    after(:create) do |schedule|
      schedule.student.save!
      schedule.sections.each { |section| section.save }
    end
  end
end
