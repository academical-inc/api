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

require 'spec_helper'

describe Academical::Routes::Sections do

  to_update = {"course_name" => "Modified Course Name" }
  to_remove = ["credits"]

  except_for_create = ["teacher_names"]
  before(:each) { make_admin true }
  let(:resource_to_create) {
    s = create(:school)
    build(:section, :with_teachers, school: s)
  }

  it_behaves_like Academical::Routes::ModelRoutes, to_update, to_remove,
    [:teachers, :schedules], [], except_for_create

  # TODO Test #students behavior
  # TODO Test expand sections behavior

end

