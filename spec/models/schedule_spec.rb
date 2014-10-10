require 'spec_helper'

describe Schedule do
  it_behaves_like Linkable, [:student, :sections, :school]

  describe 'instantiation' do
    let(:schedule) { build(:schedule) }

    it 'should instantiate a Schedule' do
      expect(schedule.class.name.demodulize).to eq("Schedule")
    end
  end

  describe 'validations' do
    let(:schedule) { build(:schedule) }

    it 'should be valid with default values' do
      expect(schedule).to be_valid
    end
  end

end
