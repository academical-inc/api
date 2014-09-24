require 'spec_helper'

describe Teacher do
  it_behaves_like Linkable, [:sections, :school]

  describe 'instantiation' do
    let(:teacher) { build(:teacher) }

    it 'should instantiate a Teacher' do
      expect(teacher.class.name.demodulize).to eq("Teacher")
    end
  end

  describe 'validations' do

    it 'should not be valid when the name is missing' do
      teacher = build(:teacher, name: {})
      expect(teacher).not_to be_valid
    end

    it 'should be invaid when part of the name is missing' do
      teacher = build(:teacher, name: build(:name, first: nil))
      expect(teacher).not_to be_valid
    end
  end

end
