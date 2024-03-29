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

describe Section do
  it_behaves_like Linkable, [:teachers, :students, :schedules]

  describe 'instantiation' do
    let(:section) { build(:section) }

    it 'should instantiate a Section' do
      expect(section.class.name.demodulize).to eq("Section")
    end
  end

  describe '#students' do
    # TODO
  end

  describe '#expand_events' do
    let(:section) { build(:section, :with_events) }

    it 'should call expand on all of its events' do
      section.events.each do |event|
        expect(event).to receive(:expand)
      end
      section.expand_events
    end

    it 'should return correct as_json representation with expanded events' do
      # TODO
    end
  end

  describe '#serializable_hash' do
    let(:section) { build(:section) }

    it 'should update the teacher names correctly' do
      t1 = build(:teacher,
                 name: build(:name, first: "John", middle: "Paul", last: "Man"))
      t2 = build(:teacher,
                 name: build(:name, first: "Jake", middle: "Pike", last: "Wow"))
      section.teachers = [t1, t2]
      hash = section.as_json
      expect(hash).to have_key("teacher_names")
      expect(hash["teacher_names"]).to eq(["John Paul Man",
                                           "Jake Pike Wow"])
    end
  end

  describe 'relations' do

    describe '#teachers' do
      let!(:teacher) { create(:teacher) }

      it "should update the teacher's sections when section created" do
        expect(teacher.sections.count).to eq(0)
        data = build(:section, teachers: [teacher], school: teacher.school).as_json
        data.delete "teacher_names"
        s = Section.create! data
        teacher.reload
        expect(teacher.sections.count).to eq(1)
        expect(teacher.sections.first).to eq(s)
      end

      it "should update the teacher's sections when section updated" do
        expect(teacher.sections.count).to eq(0)
        data = build(:section, school: teacher.school).as_json
        data.delete "teacher_names"
        s = Section.create! data
        expect(s.teachers.count).to eq(0)
        s.update_attributes! teachers: [teacher]
        teacher.reload
        expect(teacher.sections.count).to eq(1)
        expect(teacher.sections.first).to eq(s)
      end
    end
  end

  describe 'callbacks' do

    describe 'before_validation' do
      let(:section) {
        dept = build(:department, name: "terrible name")
        build(:section, :with_events, course_name: "MY AWFUL NAME", departments: [dept])
      }

      it 'titleizes corresponding fields correctly' do
        section.save!
        expect(section.course_name).to eq("My Awful Name")
        expect(section.departments.first.name).to eq("Terrible Name")
      end

      it 'sets event names accordingly' do
        section.events.each { |ev| ev.name = "" }
        section.save!
        expect(section.events).not_to be_empty
        section.events.each do |event|
          expect(event.name).to eq("My Awful Name")
        end
      end
    end

  end

  describe 'validations' do
    let(:section) { build(:section, :with_events, :with_teachers) }

    it 'should be valid with default values' do
      expect(section).to be_valid
    end

    it\
    'should not have corequisites and be corequisite_of another at same time' do
      coreq  = build(:section, course_name: "corequisite")
      parent = build(:section, course_name: "parent")

      section.corequisites << coreq
      section.corequisite_of = parent

      expect(section).not_to be_valid
    end
  end
end
