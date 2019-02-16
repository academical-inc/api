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

  factory :school_term do
    ignore do
      year 2015
      month 1
      invalid false
    end
    start_date { Date.new(year, month, 15) }
    end_date {
      d = start_date + 4.months
      d -= 1.year if invalid
      d
    }
    name { "#{start_date.year}-#{if month==1 then 1 else 2 end}" }
  end

end
