require 'spec_helper'

describe CommonHelpers do
  let(:helper) { CommonHelpers }

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

  describe '.extract!' do
    let(:hash) { {field: "value"} }
    let(:str_hash) { {"field" => "value"} }

    it 'should raise exception when key is missing from hash' do
      expect{helper.extract!(:invalid, hash)}\
        .to raise_error(ParameterMissingError)
      expect{helper.extract!("invalid", hash)}\
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

  describe '.json_error' do
    # This method is already tested by testing response utils and the routes
    # This method can't be really tested outisde a Sinatra context
  end

  describe '.json_response' do
    # This method is already tested by testing response utils and the routes
    # This method can't be really tested outisde a Sinatra context
  end
end
