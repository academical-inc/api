require 'spec_helper'

describe Student do
  it_behaves_like Linkable, [:school, :schedules, :registered_schedule]

  describe 'instantiation' do
    let(:student) { build(:student) }

    it 'should instantiate a Student' do
      expect(student.class.name.demodulize).to eq("Student")
    end
  end

  describe 'callbacks' do

    describe 'after_create' do
      let(:student) { build(:student, schedules: []) }

      it 'creates a default schedule' do
        student.save!
        expect(student.schedules.count).to eq(1)
        expect(student.schedules.first.name).to  \
          eq(I18n.t("schedule.default_name"))
      end
    end
  end

  describe 'validations' do
    context 'when email is incorrect' do
      let(:student) { build(:student) }

      it 'should not be valid' do
        student.email = "invalid"
        expect(student).not_to be_valid
        student.email = "invalid@invalid,co"
        expect(student).not_to be_valid
        student.email = "invalid@invalid"
        expect(student).not_to be_valid
      end
    end

    context 'when email is correct' do
      let(:student) { build(:student) }

      it 'should not be valid' do
        expect(student).to be_valid
      end
    end
  end

end
