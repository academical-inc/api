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

    describe '#sections' do
      let!(:section) { create(:section) }

      it "should update the section's teachers when teacher created" do
        expect(section.teachers.count).to eq(0)
        data = build(:teacher, sections: [section], school: section.school).as_json
        t = Teacher.create! data
        section.reload
        expect(section.teachers.count).to eq(1)
        expect(section.teachers.first).to eq(t)
      end

      it "should update the sections's teachers when teacher updated" do
        expect(section.teachers.count).to eq(0)
        data = build(:teacher, school: section.school).as_json
        t = Teacher.create! data
        expect(t.sections.count).to eq(0)
        t.update_attributes! sections: [section]
        section.reload
        expect(section.teachers.count).to eq(1)
        expect(section.teachers.first).to eq(t)
      end
    end

  end

  describe 'callbacks' do

    describe 'before_create' do
      let(:teacher) {
        name = build(:name, first: "JULIAN", last: "ASSANGE", middle: "e")
        build(:teacher, name: name)
      }

      it 'titleizes name correctly' do
        teacher.save!
        expect(teacher.name.first).to eq("Julian")
        expect(teacher.name.middle).to eq("E")
        expect(teacher.name.last).to eq("Assange")
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
