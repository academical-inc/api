require 'spec_helper'

describe School do

  describe 'instantiation' do
    let!(:school) { build(:school) }
    let!(:base_name) { "Academical::Models::" }

    it 'should instantiate a School' do
      expect(school.class.name).to eq("#{base_name}School")
    end
  end

end
