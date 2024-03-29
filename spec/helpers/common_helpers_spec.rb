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

require 'spec_helper'

describe CommonHelpers do
  let(:helper) { CommonHelpers }

  describe '.get_result' do
    before(:each) do
      create_list(:student, 2)
    end
    let(:all) { Student.all }
    let(:one) { Student.first }

    context 'when result is nil' do
      it 'should return 0 when count requested' do
        expect(helper.get_result(nil, true)).to eq(0)
      end

      it 'should return nil when result requested' do
        expect(helper.get_result(nil, false)).to be_nil
      end
    end

    context 'when result is iterable' do
      it 'should return the count when requested' do
        expect(helper.get_result(all, true)).to eq(2)
      end

      it 'should return the result when requested' do
        expect(helper.get_result(all, false)).to eq(all)
      end
    end

    context 'when result is single' do
      it 'should return the count when requested' do
        expect(helper.get_result(one, true)).to eq(1)
      end

      it 'should return the result when requested' do
        expect(helper.get_result(one, false)).to eq(one)
      end
    end
  end

  describe '.remove_key' do
    let(:hash) { {field: "value"} }

    it 'should remove the key regardless of string or symbol' do
      expect(helper.remove_key(:field, hash)).to eq({})
      expect(helper.remove_key("field", hash)).to eq({})
    end

    it 'should not remove the key if it is not present' do
      expect(helper.remove_key(:f, hash)).to eq(hash)
      expect(helper.remove_key(:f, hash)).to eq(hash)
    end
  end

  describe '.contains?' do
    let(:hash) { {field: "value"} }

    it\
    'should indicate if the hash contains the key regardless of string or sym' do
      expect(helper.contains?(:field, hash)).to be(true)
      expect(helper.contains?("field", hash)).to be(true)
    end

    it 'should indicate if the hash does not contain the key' do
      expect(helper.contains?(:invalid, hash)).to be(false)
      expect(helper.contains?("invalid", hash)).to be(false)
    end
  end

  describe '.extract' do
    let(:hash) { {field: "value"} }
    let(:str_hash) { {"field" => "value"} }

    it 'should return nil when key is missing from hash' do
      expect(helper.extract(:invalid, hash)).to be_nil
      expect(helper.extract("invalid", hash)).to be_nil
    end

    it 'should return the correct value from the hash given a symbol key' do
      expect(helper.extract(:field, hash)).to eq("value")
      expect(helper.extract(:field, str_hash)).to eq("value")
    end

    it 'should return the correct value from the hash given a string key' do
      expect(helper.extract("field", hash)).to eq("value")
      expect(helper.extract("field", str_hash)).to eq("value")
    end
  end

  describe '.extract!' do
    let(:hash) { {field: "value"} }
    let(:str_hash) { {"field" => "value"} }
    before(:each) do
      allow(CommonHelpers).to receive(:params) { hash }
    end

    it\
    'should raise key err when key is missing and hash is explicitly set' do
      expect{helper.extract!(:invalid, hash)}\
        .to raise_error(KeyError)
      expect{helper.extract!("invalid", hash)}\
        .to raise_error(KeyError)
    end

    it\
    'should raise param missing when key is missing and hash is not explicitly set' do
      expect{helper.extract!(:invalid)}\
        .to raise_error(ParameterMissingError)
      expect{helper.extract!("invalid")}\
        .to raise_error(ParameterMissingError)
    end

    it 'should return the correct value from the hash given a symbol key' do
      expect(helper.extract!(:field, hash)).to eq("value")
      expect(helper.extract!(:field, str_hash)).to eq("value")
    end

    it 'should return the correct value from the hash given a string key' do
      expect(helper.extract!("field", hash)).to eq("value")
      expect(helper.extract!("field", str_hash)).to eq("value")
    end
  end

  describe '.extract_nested!' do
    let(:n2) { {k5: "v5"} }
    let(:n1) { {k3: "v3", k4: n2} }
    let(:hash) { {k1: "v1", k2: n1} }
    before(:each) do
      allow(CommonHelpers).to receive(:params) { hash }
    end

    it 'should raise param missing when hash not explicitly set' do
      expect{ helper.extract_nested!("k0.k2") }\
        .to raise_error(ParameterMissingError)
      expect{ helper.extract_nested!("k1.k0.k2") }\
        .to raise_error(ParameterMissingError)
      expect{ helper.extract_nested!("k1.k2.k5") }\
        .to raise_error(ParameterMissingError)
    end

    it 'should raise exception when first key missing from the hash' do
      expect{ helper.extract_nested!("k0.k2", hash) }\
        .to raise_error
    end

    it 'should raise exception when middle key missing from the hash' do
      expect{ helper.extract_nested!("k1.k0.k3", hash) }\
        .to raise_error
    end

    it 'should raise exception when last key missing from the hash' do
      expect{ helper.extract_nested!("k1.k2.k5", hash) }\
        .to raise_error
    end

    it 'should return the correct value for the first key' do
      expect(helper.extract_nested!("k1", hash)).to eq("v1")
      expect(helper.extract_nested!("k2", hash)).to eq(n1)
    end

    it 'should return the correct value for middle key' do
      expect(helper.extract_nested!("k2.k3", hash)).to eq("v3")
      expect(helper.extract_nested!("k2.k4", hash)).to eq(n2)
    end

    it 'should return the correct value for last key' do
      expect(helper.extract_nested!("k2.k4.k5", hash)).to eq("v5")
    end
  end

  describe '.extract_all!' do
    let(:ks) { [:k2, :k5] }
    let(:nested_ks) { [:"k2.k3", :"k2.k4", :k5] }
    let(:nested) { {k1: "v1", k2: {k3: "v2", k4: "v3"}, k5: "v4"} }
    let(:single) { {k1: "v1", k2: "v2", k5: "v3"} }

    it 'should correctly extract values for keys when single hash' do
      expect(helper.extract_all!(ks, single)).to\
        eq({"k2" => "v2", "k5" => "v3"})
    end

    it 'should correctly extract values for keys when nested hash' do
      expect(helper.extract_all!(nested_ks, nested)).to\
        eq({"k2.k3" => "v2", "k2.k4" => "v3", "k5" => "v4"})
    end

    it 'should raise error when provided keys do not exist in single hash' do
      expect{ helper.extract_all!([:k2, :k6], single) }.to\
        raise_error(KeyError)
    end

    it 'should raise error when provided keys do not exist in nested hash' do
      expect{ helper.extract_all!([:k1, "k2.k5"], nested) }.to\
        raise_error
    end
  end

  describe '.json' do
    let(:h) { {data: "data"} }
    let(:settings) { double "settings", api_content_type: :json,\
                     api_charset: :utf }
    before(:each) do
      allow(helper).to receive(:settings) { settings }
    end

    it 'should set the correct content type and charset' do
      expect(helper).to receive(:content_type).with(:json, charset: :utf)
      helper.json h, camelize: false
    end

    it 'should camelize hash if camelize specified' do
      allow(helper).to receive(:content_type)
      expect(helper).to receive(:camelize_hash_keys).with(h)
      helper.json h, camelize: true
    end
  end

  describe '.camelize_hash_keys' do
    let(:h) {
      { k_one: 1, k_two: {k_three: 2}, k_four: [3, 4, {k_five: 5}]  }
    }

    it 'camelizes hash keys correctly' do
      expect(helper.camelize_hash_keys(h)).to eq(
        { "kOne"=>1, "kTwo"=>{"kThree"=>2}, "kFour"=>[3,4,{"kFive"=>5}] }
      )
    end
  end

  describe '.json_error' do
    # This method is already tested by testing response utils and the routes
    # This method can't be really tested outisde a Sinatra context
  end

  describe '.json_response' do
    # This method is already tested by testing response utils and the routes
    # This method can't be really tested outisde a Sinatra context
  end
end
