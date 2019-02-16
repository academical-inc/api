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

  factory :event_recurrence do

    ignore do
      start_dt DateTime.new(2015,1,15,11,0).utc
    end

    freq "WEEKLY"
    repeat_until { (start_dt + 4.months).utc }

    event { build(:event) }

    trait :with_days do
      days_of_week ["MO", "WE"]
    end

  end
end

