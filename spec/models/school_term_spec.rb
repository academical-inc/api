require 'spec_helper'

describe SchoolTerm do

  describe 'instantiation' do
    let(:term) { build(:school_term) }

    it 'should instantiate a SchoolTerm' do
      expect(term.class.name.demodulize).to eq("SchoolTerm")
    end
  end

  describe 'validations' do

    it 'should not be valid when dates are not correct' do
      term = build(:school_term, invalid:true)
      expect(term).not_to be_valid
    end

    it 'should be valid when dates are correct' do
      term = build(:school_term)
      expect(term).to be_valid
    end
  end

end
