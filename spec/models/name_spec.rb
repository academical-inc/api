require 'spec_helper'

describe Name do

  describe 'instantiation' do
    let(:name) { build(:name) }

    it 'should instantiate a Name' do
      expect(name.class.name.demodulize).to eq("Name")
    end
  end

  describe '#full_name' do
    let!(:name) { build(:name,
                        first: "John", middle: "Sebastian", last: "Doe") }

    it 'should return the correct name' do
      expect(name.full_name).to eq "John Sebastian Doe"
    end

    it 'should not include middle name when not present' do
      middle = name.middle
      name.middle = ""
      expect(name.full_name).not_to include(middle)
      name.middle = nil
      expect(name.full_name).not_to include(middle)
    end

    it 'should include other name when specified' do
      other = name.other
      expect(name.full_name).not_to include(other)
      expect(name.full_name(include_other: true)).to include(other)
    end

    it 'should not include other name when not present' do
      other = name.other
      name.other = ""
      expect(name.full_name(include_other: true)).not_to include(other)
      name.other = nil
      expect(name.full_name(include_other: true)).not_to include(other)
    end

    it 'should truncate when specified' do
      name.last = "Last"*10
      # account for 2 spaces
      full_l = name.first.length + name.middle.length + name.last.length + 2

      truncated = name.full_name(trunc_length: 30)
      expect(truncated.length).to eq(30)
      expect(truncated).to end_with("...")

      not_trunc = name.full_name(truncate: false)
      expect(not_trunc.length).to eq(full_l)
      expect(not_trunc).to end_with("Last")
    end
  end

  describe '#titleize_name' do
    let!(:name) { build(:name,
                        first: "JIM", middle: "ED-ward", last: "fallon") }

    it 'titleizes entire name correctly' do
      name.titleize_name
      expect(name.first).to eq("Jim")
      expect(name.middle).to eq("Ed-Ward")
      expect(name.last).to eq("Fallon")
    end
  end
end
