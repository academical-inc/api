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

describe Teacher do
  it_behaves_like Linkable, [:sections]

  describe 'instantiation' do
    let(:teacher) { build(:teacher) }

    it 'should instantiate a Teacher' do
      expect(teacher.class.name.demodulize).to eq("Teacher")
    end
  end

  describe 'relations' do

    describe '#sections' do
      let!(:section) { create(:section) }

      it "should update the section's teachers when teacher created" do
        expect(section.teachers.count).to eq(0)
        data = build(:teacher, sections: [section], school: section.school).as_json
        t = Teacher.create! data
        section.reload
        expect(section.teachers.count).to eq(1)
        expect(section.teachers.first).to eq(t)
      end

      it "should update the sections's teachers when teacher updated" do
        expect(section.teachers.count).to eq(0)
        data = build(:teacher, school: section.school).as_json
        t = Teacher.create! data
        expect(t.sections.count).to eq(0)
        t.update_attributes! sections: [section]
        section.reload
        expect(section.teachers.count).to eq(1)
        expect(section.teachers.first).to eq(t)
      end
    end

  end

  describe 'validations' do

    it 'should not be valid when the name is missing' do
      teacher = build(:teacher, name: {})
      expect(teacher).not_to be_valid
    end

    it 'should be invaid when part of the name is missing' do
      teacher = build(:teacher, name: build(:name, first: nil))
      expect(teacher).not_to be_valid
    end
  end

end
