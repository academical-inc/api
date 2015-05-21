require 'spec_helper'

describe Student do
  it_behaves_like Linkable, [:schedules, :registered_schedule]

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
    let!(:student) { build(:student) }

    it 'should not be valid email is incorrect' do
      student.email = "invalid"
      expect(student).not_to be_valid
      student.email = "invalid@invalid,co"
      expect(student).not_to be_valid
      student.email = "invalid@invalid"
      expect(student).not_to be_valid
    end

    it 'should be valid when email is correct' do
      expect(student).to be_valid
    end

    it 'should be valid when number of schedules does not exceed max' do
      student.schedules = build_list(:schedule, Student::MAX_SCHEDULES)
      expect(student).to be_valid
      student.schedules = build_list(:schedule, 1)
      expect(student).to be_valid
    end

    it 'should be invalid when number of schedules exceeds max' do
      student.schedules = build_list(:schedule, Student::MAX_SCHEDULES + 1)
      expect(student).not_to be_valid
      student.save!
    end

  end

end
