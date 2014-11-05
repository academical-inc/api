require 'spec_helper'

describe Section do
  it_behaves_like Linkable, [:teachers, :students, :schedules, :school]

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

  describe '#update_teacher_names' do
    let(:section) { build(:section) }

    it 'should update the teacher names correctly' do
      t1 = build(:teacher,
                 name: build(:name, first: "John", middle: "Paul", last: "Man"))
      t2 = build(:teacher,
                 name: build(:name, first: "Jake", middle: "Pike", last: "Wow"))
      section.teachers = [t1, t2]
      section.update_teacher_names
      expect(section.teacher_names).to eq(["John Paul Man",
                                           "Jake Pike Wow"])
    end
  end

  describe 'relations' do

    describe '#teachers' do
      let!(:teacher) { create(:teacher) }

      it "should update the teacher's sections when section created" do
        expect(teacher.sections.count).to eq(0)
        data = build(:section, teachers: [teacher], school: teacher.school).as_json
        s = Section.create! data
        teacher.reload
        expect(teacher.sections.count).to eq(1)
        expect(teacher.sections.first).to eq(s)
      end

      it "should update the teacher's sections when section updated" do
        expect(teacher.sections.count).to eq(0)
        data = build(:section, school: teacher.school).as_json
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
    describe 'before save' do
      let(:section) { build(:section) }

      it 'should update the teacher names when creating' do
        expect(section).to receive(:update_teacher_names).once
        section.save!
      end

      it 'should update the teacher names when updating' do
        section.save!
        expect(section).to receive(:update_teacher_names).once.and_call_original
        section.update_attributes!\
          teachers: [build(:teacher, sections: [section])]
        expect(section.teacher_names.count).to eq(1)
      end
    end
  end

  describe 'validations' do
    let(:section) { build(:section, :with_events, :with_teachers) }

    it 'should be valid with default values' do
      expect(section).to be_valid
    end
  end
end
