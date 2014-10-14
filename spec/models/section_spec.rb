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
      expect(section.teacher_names).to eq(["John_2 Paul_2 Doe_2",
                                           "John_3 Paul_3 Doe_3"])
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
