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
          eq(I18n.t("schedule.default_name", locale: student.school.locale))
      end
    end
  end

  describe 'defaults' do
    # These tests avoid using FactoryGirl build/create methods.
    # To understand why see http://bit.ly/2BRVr21

    it 'creates a default picture if none given' do
      expected_picture = 'https://s.gravatar.com/avatar/1aedb8d9dc4751e229a335e371db8058?s=480&r=pg&d=mm'
      student = Student.new email: 'test@gmail.com'
      expect(student.picture).to eq(expected_picture)
    end

    it 'does not assign a default picture if one is provided' do
      picture = 'https://something.url.com'
      student = Student.new email: 'test@gmail.com', picture: picture
      expect(student.picture).to eq(picture)
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
    end

  end

end
