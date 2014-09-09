require 'spec_helper'

describe Section do
  it_behaves_like Linkable, [:teachers, :students, :schedules]

  describe 'instantiation' do
    let(:section) { build(:section) }

    it 'should instantiate a Section' do
      expect(section.class.name.demodulize).to eq("Section")
    end
  end

  describe '#update_teacher_names' do
    let(:section) { build(:section, :with_teachers) }

    it 'should update the teacher names correctly' do
      section.update_teacher_names
      expect(section.teacher_names).to eq(["John Sebastian Doe",
                                           "John Sebastian Doe"])
    end
  end

  describe 'callbacks' do
    describe 'before creation' do
      let(:section) { build(:section, :with_teachers) }

      it 'should update the teacher names' do
        expect(section).to receive(:update_teacher_names).once
        section.save
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
