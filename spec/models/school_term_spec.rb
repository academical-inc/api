require 'spec_helper'

describe SchoolTerm do

  describe 'instantiation' do
    let(:term) { build(:school_term) }

    it 'should instantiate a SchoolTerm' do
      expect(term.class.name.demodulize).to eq("SchoolTerm")
    end
  end

  describe '#dates_correct?' do
    let(:term) { build(:school_term) }
    let(:inv_term) { build(:school_term, invalid: true) }

    it 'should return true if start_date is before end_date' do
      expect(term.dates_correct?).to be(true)
    end

    it 'should return false if start_date is after end_date' do
      expect(inv_term.dates_correct?).to be(false)
    end
  end

  describe 'validations' do
    let(:term) { build(:school_term, invalid:true) }

    it 'should not be valid when dates are not correct' do
      expect(term).not_to be_valid
    end
  end

end
