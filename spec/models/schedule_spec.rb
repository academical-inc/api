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

describe Schedule do
  it_behaves_like Linkable, [:sections, :events]

  describe 'instantiation' do
    let(:schedule) { build(:schedule) }

    it 'should instantiate a Schedule' do
      expect(schedule.class.name.demodulize).to eq("Schedule")
    end
  end

  describe '#as_json' do
    let(:schedule) { create(:schedule) }

    it 'builds hash with sections included when @include_sections = true' do
      schedule.include_sections = true
      expect(schedule.sections.count).to eq(2)
      res = schedule.as_json
      expect(res).to have_key("sections")
      expect(res["sections"].count).to eq(2)
    end

    it 'builds hash with sections included when @include_sections = true' do
      schedule.include_sections = false
      expect(schedule.sections.count).to eq(2)
      res = schedule.as_json
      expect(res).not_to have_key("sections")
    end
  end

  describe 'validations' do
    let(:schedule) { build(:schedule) }

    it 'should be valid with default values' do
      expect(schedule).to be_valid
    end

    it 'should be invalid when name length exceeds max' do
      schedule.name = ("n" * Schedule::MAX_NAME_LENGTH) + "n"
      expect(schedule).not_to be_valid
    end

    it 'should be invalid when name length is 0' do
      schedule.name = ""
      expect(schedule).not_to be_valid
    end

    it 'should be valid when name length does not exceed max' do
      schedule.name = ("n" * Schedule::MAX_NAME_LENGTH)
      expect(schedule).to be_valid
      schedule.name = "n" * (Schedule::MAX_NAME_LENGTH-1)
      expect(schedule).to be_valid
    end
  end

end
