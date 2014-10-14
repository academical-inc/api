require 'spec_helper'

describe Teacher do
  it_behaves_like Linkable, [:sections, :school]

  describe 'instantiation' do
    let(:teacher) { build(:teacher) }

    it 'should instantiate a Teacher' do
      expect(teacher.class.name.demodulize).to eq("Teacher")
    end
  end

  describe 'relations' do

    describe 'autosave #sections' do
      let!(:section) { create(:section) }

      it "should update the section's teachers when teacher saved" do
        expect(section.teachers.count).to eq(0)
        t = create(:teacher, sections: [section])
        expect(t.sections.count).to eq(1)
        expect(t.sections.first).to eq(section)
        section.reload
        expect(section.teachers.count).to eq(1)
        expect(section.teachers.first).to eq(t)
      end
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
