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
    let(:section) { build(:section, :with_teachers) }

    it 'should update the teacher names correctly' do
      section.update_teacher_names
      expect(section.teacher_names).to eq(["John_1 Paul_1 Doe_1",
                                           "John_2 Paul_2 Doe_2"])
    end
  end

  describe 'relations' do

    describe 'autosave #teachers' do
      let!(:teacher) { create(:teacher) }

      it "should update the teacher's sections when teacher saved" do
        expect(teacher.sections.count).to eq(0)
        s = create(:section, teachers: [teacher])
        expect(s.teachers.count).to eq(1)
        expect(s.teachers.first).to eq(teacher)
        teacher.reload
        expect(teacher.sections.count).to eq(1)
        expect(teacher.sections.first).to eq(s)
      end
    end
  end

  describe 'callbacks' do
    describe 'before save' do
      let(:section) { build(:section, :with_teachers) }

      it 'should update the teacher names when creating' do
        expect(section).to receive(:update_teacher_names).once
        section.save!
      end

      it 'should update the teacher names when updating' do
        section.save!
        expect(section).to receive(:update_teacher_names).once
        section.teachers = [build(:teacher)]
        section.save!
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
