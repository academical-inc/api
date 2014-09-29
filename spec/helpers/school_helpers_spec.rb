require 'spec_helper'

describe SchoolHelpers do
  let(:helper) { SchoolHelpers }
  let(:andes) { build(:school) }
  let(:rosario) { build(:school, name: "Rosario") }

  before(:each) do
    allow(SchoolHelpers).to receive(:get_result) { |*args|
      CommonHelpers.get_result(*args)
    }
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

  describe '.upsert_school' do

    context 'when school does not exist' do

      it 'should create a new school correctly' do
        data = {school: "data"}
        expect(helper).to receive(:create_school).with(data)
        _, code = helper.upsert_school data, nil
        expect(code).to eq(201)
      end
    end

    context 'when school already exists' do
      let(:modified) {
        andes.name = "modified"
        andes.as_json
      }

      it 'should update the school correctly' do
        expect(helper).to receive(:school).with(andes.id.to_s).and_call_original\
          .at_least(:once)
        _, code = helper.upsert_school(modified, andes.id.to_s)
        expect(helper.school(andes.id.to_s).name).to eq(modified["name"])
        expect(code).to eq(200)
      end
    end
  end

end
