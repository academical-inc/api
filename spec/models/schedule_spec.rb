require 'spec_helper'

describe Schedule do
  it_behaves_like Linkable, [:sections, :events]

  describe 'instantiation' do
    let(:schedule) { build(:schedule) }

    it 'should instantiate a Schedule' do
      expect(schedule.class.name.demodulize).to eq("Schedule")
    end
  end

  describe '#as_json' do
    let(:schedule) { create(:schedule) }

    it 'builds hash with sections included when @include_sections = true' do
      schedule.include_sections = true
      expect(schedule.sections.count).to eq(2)
      res = schedule.as_json
      expect(res).to have_key("sections")
      expect(res["sections"].count).to eq(2)
    end

    it 'builds hash with sections included when @include_sections = true' do
      schedule.include_sections = false
      expect(schedule.sections.count).to eq(2)
      res = schedule.as_json
      expect(res).not_to have_key("sections")
    end
  end

  describe 'validations' do
    let(:schedule) { build(:schedule) }

    it 'should be valid with default values' do
      expect(schedule).to be_valid
    end

    it 'should be invalid when name length exceeds max' do
      schedule.name = ("n" * Schedule::MAX_NAME_LENGTH) + "n"
      expect(schedule).not_to be_valid
    end

    it 'should be invalid when name length is 0' do
      schedule.name = ""
      expect(schedule).not_to be_valid
    end

    it 'should be valid when name length does not exceed max' do
      schedule.name = ("n" * Schedule::MAX_NAME_LENGTH)
      expect(schedule).to be_valid
      schedule.name = "n" * (Schedule::MAX_NAME_LENGTH-1)
      expect(schedule).to be_valid
    end
  end

end
