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

  sequence(:event_name) { |n| "Event #{n}" }

  factory :event do
    start_dt Time.new(2015,1,15,11,0).utc
    end_dt Time.new(2015,1,15,12,30).utc

    location "Somewhere on earth"
    timezone "America/Bogota"
    name     { generate :event_name }

    trait :with_recurrence do
      recurrence { build(:event_recurrence, :with_days, start_dt: start_dt) }
    end

    trait :with_section do
      section { build(:section) }
    end
  end

end
