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

  sequence(:school_name) { |n| "University #{n}" }

  factory :school do

    name { generate :school_name }
    nickname { name.underscore.gsub(" ", "_") }
    locale "es"
    timezone "America/Bogota"

    identity_providers { ["facebook"] }
    departments { build_list(:department, 5) }
    terms { [build(:school_term), build(:school_term, year: 2014, month: 8), \
             build(:school_term, year: 2014)] }
    assets { build(:school_assets) }
    app_ui { build(:app_ui) }

    initialize_with { School.find_or_create_by(name: name) }
  end

end
