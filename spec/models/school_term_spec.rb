require 'spec_helper'

describe SchoolTerm do

  describe 'instantiation' do
    let(:term) { build(:school_term) }

    it 'should instantiate a SchoolTerm' do
      expect(term.class.name.demodulize).to eq("SchoolTerm")
    end
  end

  describe 'validations' do

    it 'should be valid whith default values' do
      term = build(:school_term)
      expect(term).to be_valid
    end

    it 'should not be valid when dates are not correct' do
      term = build(:school_term, invalid:true)
      expect(term).not_to be_valid
    end

    it 'should not be valid when start_date is nil' do
      term = build(:school_term)
      term.start_date = nil
      expect(term).not_to be_valid
    end

    it 'should not be valid when end_date is nil' do
      term = build(:school_term)
      term.end_date = nil
      expect(term).not_to be_valid
    end

  end

end
