require 'spec_helper'

describe SchoolHelpers do
  let(:helper) { SchoolHelpers }
  let(:andes) { build(:school) }
  let(:rosario) { build(:school, name: "Rosario") }

  before(:each) do
    andes.save!
    rosario.save!
  end

  describe '.schools' do

    context 'when not querying for count' do
      it 'should return an empty result set when no schools present' do
        School.delete_all
        expect(helper.schools(count: false).length).to eq(0)
      end

      it 'should return all schools when no where clause provided' do
        expect(helper.schools(count: false).length).to eq(2)
      end

      it 'should return correct result set based on where clause' do
        res = helper.schools(where: {name: "Rosario"}, count: false)
        expect(res.length).to eq(1)
        expect(res[0]).to eq(rosario)
      end
    end

    context 'when querying for count' do
      it 'should return correct count when empty' do
        School.delete_all
        expect(helper.schools(count: true)).to eq(0)
      end

      it 'should return correct count when querying all schools' do
        expect(helper.schools(count: true)).to eq(2)
      end

      it 'should return correct count based on where clause' do
        res = helper.schools(where: {name: "Rosario"}, count: true)
        expect(res).to eq(1)
      end

    end
  end

  describe '.school' do

    it 'should find the correct school given the id' do
      expect(helper.school(andes.id)).to eq(andes)
      expect(helper.school(rosario.id)).to eq(rosario)
    end

    it 'should raise a not found error when the id is incorrect' do
      expect{helper.school(1)}.to raise_error(Mongoid::Errors::DocumentNotFound)
    end
  end

  describe '.create_school' do
    let(:new_school) { build(:school, name: "TestU") }
    let(:data) { new_school.as_json }

    it 'should create a new school correctly' do
      n_s = helper.create_school data
      expect(helper.schools(count: false).length).to eq(3)
      expect(n_s).to be
      expect{helper.school(n_s.id)}.not_to raise_error
    end

    it 'should raise a validation error when data is incomplete' do
      expect {
        helper.create_school name: "data"
      }.to raise_error(Mongoid::Errors::Validations)
    end

    it\
    'should raise dynamic field error when attempting to create diff fields' do
      expect {
        helper.create_school invalid: "data"
      }.to raise_error(Mongoid::Errors::UnknownAttribute)
    end
  end

end
