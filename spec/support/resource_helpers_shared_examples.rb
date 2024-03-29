#
# Copyright (C) 2012-2019 Academical Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#


shared_examples_for "resource_helpers_for" do |model|
  let(:helper) { ResourceHelpers }
  let(:factory) { model.name.demodulize.underscore.to_sym }
  let!(:resource_list) { create_list(factory, 2) }
  let!(:r1) { resource_list[0] }
  let!(:r2) { resource_list[1] }
  let(:query_data) {
    r1.as_json.slice(*r1.class.uniq_field_groups.first.map {|f| f.to_s})
  }

  before(:each) do
    allow(ResourceHelpers).to receive(:get_result) { |*args|
      CommonHelpers.get_result(*args)
    }
    allow(ResourceHelpers).to receive(:remove_key) { |*args|
      CommonHelpers.remove_key(*args)
    }
    allow(ResourceHelpers).to receive(:extract_all!) { |*args|
      CommonHelpers.extract_all!(*args)
    }
    allow(ResourceHelpers).to receive(:extract!) { |*args|
      CommonHelpers.extract!(*args)
    }
    allow(ResourceHelpers.class).to receive(:model) { model }
  end

  describe '.resources' do

    context 'when not querying for count' do
      it 'should return an empty result set when no resources present' do
        model.delete_all
        expect(helper.resources(count:false).length).to eq(0)
      end

      it 'should return all resources when no where clause provided' do
        expect(helper.resources(count:false).length).to eq(2)
      end

      it 'should return correct result set based on where clause' do
        res = helper.resources(where: query_data, count: false)
        expect(res.length).to eq(1)
        expect(res[0]).to eq(r1)
      end
    end

    context 'when querying for count' do
      it 'should return correct count when empty' do
        model.delete_all
        expect(helper.resources(count: true)).to eq(0)
      end

      it 'should return correct count when querying all resources' do
        expect(helper.resources(count: true)).to eq(2)
      end

      it 'should return correct count based on where clause' do
        res = helper.resources(where: query_data, count: true)
        expect(res).to eq(1)
      end
    end
  end

  describe '.resource' do

    it 'should find the correct resource given the id' do
      expect(helper.resource(r1.id)).to eq(r1)
      expect(helper.resource(r2.id)).to eq(r2)
    end

    it 'should raise a not found error when the id is incorrect' do
      expect{helper.resource("non_existent")}.to\
        raise_error(Mongoid::Errors::DocumentNotFound)
    end
  end

  describe '.resource_by' do
    # TODO This is basically what mongo does, not so urgent to test
  end

  describe '.resource_first_match' do
    # TODO
  end

  describe '.create_resource' do
    let(:new_res) { build(factory) }
    let(:data) { new_res.as_json }

    it 'should create a new school correctly' do
      n = helper.create_resource data
      expect(helper.resources(count: false).length).to eq(3)
      expect(n).to be
      expect{helper.resource(n.id)}.not_to raise_error
    end

    it 'should raise a validation error when data is incomplete' do
      incomplete = data.except(
        *new_res.class.uniq_field_groups.first.map {|f| f.to_s}
      )
      expect {
        helper.create_resource incomplete
      }.to raise_error(Mongoid::Errors::Validations)
    end

    it 'should raise dynamic field error creating with diff fields' do
      expect {
        helper.create_resource invalid: "data"
      }.to raise_error(Mongoid::Errors::UnknownAttribute)
    end

    it 'should raise duplicate key error when repeating unique data' do
      expect{
        helper.create_resource r1.as_json
      }.to raise_error(Mongoid::Errors::DuplicateKey)
    end
  end

  describe '.update_resource' do
    # TODO
  end

  describe '.update_resources' do

    it 'should update all provided resources correctly' do
      data = [
        {id: r1.id, name: "New Name 1"},
        {id: r2.id, name: "New Name 2"}
      ]
      expect(helper.update_resources(data)).to eq(2)
      expect(helper.resource(r1.id).name).to eq("New Name 1")
      expect(helper.resource(r2.id).name).to eq("New Name 2")
    end

    it 'should raise exception if data is not an array' do
      data = {id: r1.id, name: "New Name 1"}
      expect{helper.update_resources(data)}.to raise_error(InvalidParameterError)
    end

    it 'should raise exception if any of the ids do not exist' do
      data = [
        {id: r1.id, name: "New Name 1"},
        {id: "1234", name: "New Name 2"}
      ]
      expect{helper.update_resources(data)}.to\
        raise_error(Mongoid::Errors::DocumentsNotFound,
                    "1 out of 2 resources where not found")
      expect(helper.resource(r1.id).name).to eq("New Name 1")
    end
  end

  describe '.upsert_resource' do
    let(:new_res) { build(factory) }
    let(:data) { new_res.as_json }

    context 'when resource does not exist' do

      it 'should create the new resource correctly' do
        expect(helper).to receive(:create_resource).with(
          helper.remove_key(:id, data)
        )
        _, code = helper.upsert_resource data
        expect(code).to eq(201)
      end
    end

    context 'when resource already exists' do
      let(:modified) {
        r1_data = r1.as_json
        r1_data["name"] = "modified"
        r1_data
      }

      it 'should update the resource correctly' do
        _, code = helper.upsert_resource(modified)
        expect(helper.resource(r1.id).name).to eq("modified")
        expect(code).to eq(200)
      end
    end
  end

  describe '.delete_resource' do
    # TODO This is basically what mongo does, not so urgent to test
  end

end
