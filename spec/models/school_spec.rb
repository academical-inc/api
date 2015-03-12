require 'spec_helper'

describe School do
  it_behaves_like Linkable, [:teachers, :sections, :students, :schedules]

  describe 'instantiation' do
    let(:school) { build(:school) }

    it 'should instantiate a School' do
      expect(school.class.name.demodulize).to eq("School")
    end
  end

  describe '#terms.latest_term' do
    let(:school) { build(:school) }

    it 'should return the most recent (latest) term' do
      latest_term = school.terms.latest_term
      expect(latest_term.start_date).to eq(Date.new(2015, 1, 15))
    end
  end

  describe '#set_utc_offset' do
    let(:school) { build(:school, timezone: "America/Bogota") }

    it 'sets utc_offset in minutes depending on timezone' do
      school.set_utc_offset
      expect(school.utc_offset).to eq(-300)
    end
  end

  describe 'callbacks' do

    describe 'before_save' do
      let(:school) { build(:school) }

      it 'inits utc_offset after creating school' do
        school.save!
        school.reload
        expect(school.utc_offset).not_to be_nil
      end

      it 'inits utc_offset after updating school' do
        school.save!
        school.update_attributes! timezone: "America/Bogota"
        school.reload
        expect(school.utc_offset).to eq(-300)
      end
    end

  end

  describe 'validations' do
    let!(:school) { build(:school) }

    it 'should be valid with default values' do
      expect(school).to be_valid
    end

    it 'should not be valid when departments is missing' do
      school.departments = []
      expect(school).not_to be_valid
      school.departments = [ build(:department, name: "") ]
      expect(school).not_to be_valid
    end

    it 'should not be valid when terms is missing' do
      school.terms = []
      expect(school).not_to be_valid
      school.terms = [ build(:school_term, name: "") ]
      expect(school).not_to be_valid
    end

    it 'should be invalid if timezone is not present' do
      school.timezone = nil
      expect(school).not_to be_valid
    end
  end
end
