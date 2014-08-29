require 'spec_helper'

describe School do

  def assert_links(school)
    _id = school._id
    expect(school.links[:self]).to eq("/schools/#{_id}")
    expect(school.links[:teachers]).to eq("/schools/#{_id}/teachers")
    expect(school.links[:sections]).to eq("/schools/#{_id}/sections")
    expect(school.links[:students]).to eq("/schools/#{_id}/students")
    expect(school.links[:schedules]).to eq("/schools/#{_id}/schedules")
  end

  describe 'instantiation' do
    let(:school) { build(:school) }

    it 'should instantiate a School' do
      expect(school.class.name).to eq("#{base_model_name}School")
    end
  end

  describe '#update_links' do
    let!(:_id) { "4f8583b5e5a4e46a64000002" }
    let(:school) { build(:school, _id: _id) }

    it 'should update the links hash correctly' do
      expect(school.links).to eq({})
      school.update_links
      assert_links school
    end
  end

  describe '#terms.latest_term' do
    let(:school) { build(:school) }

    it 'should return the most recent (latest) term' do
      latest_term = school.terms.latest_term
      expect(latest_term.start_date).to eq(Date.new(2015, 1, 15))
    end
  end

  describe 'callbacks' do
    let(:school) { create(:school) }

    context 'before creation' do
      it 'should update the links' do
        assert_links(school)
      end
    end
  end

  describe 'validations' do
    context 'when name is missing' do
      let(:school) { build(:school, name: nil) }

      it 'should not be valid' do
        expect(school).not_to be_valid
      end
    end

    context 'when locale is missing' do
      let(:school) { build(:school, locale: nil) }

      it 'should not be valid' do
        expect(school).not_to be_valid
      end
    end

    context 'when departments is missing' do
      let(:school) { build(:school, departments: nil) }

      it 'should not be valid' do
        expect(school).not_to be_valid
      end
    end

    context 'when terms is missing' do
      let(:school) { build(:school, terms: nil) }

      it 'should not be valid' do
        expect(school).not_to be_valid
      end
    end
  end
end
