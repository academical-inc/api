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

  describe '.each_nested_key_val' do
    let(:nested) { {key1: "val1", key2: {key3: "val2", key4: "val3"}} }
    let(:single) { {key1: "val1", key2: "val2"} }
    let(:dbl_nstd) { {key1: "val1", key2: {key3: "val2",
                                           key4: {key5: "val3", key6: "val4"}}} }

    it 'should yield the correct keys and values when no nested hash' do
      expect{ |b| helper.each_nested_key_val "root", single, &b }.to\
        yield_successive_args(["root.key1", "val1"], ["root.key2", "val2"])
    end

    it 'should yield the correct keys and values when nested hash' do
      expect{ |b| helper.each_nested_key_val "root", nested, &b }.to\
        yield_successive_args(["root.key1", "val1"],
                              ["root.key2.key3", "val2"],
                              ["root.key2.key4", "val3"])
    end

    it 'should yield the correct keys and values when multiple nested hash' do
      expect{ |b| helper.each_nested_key_val "root", dbl_nstd, &b }.to\
        yield_successive_args(["root.key1", "val1"],
                              ["root.key2.key3", "val2"],
                              ["root.key2.key4.key5", "val3"],
                              ["root.key2.key4.key6", "val4"])
    end

    it 'should not yield any key value pairs when empty hash' do
      expect{ |b| helper.each_nested_key_val "root", single, &b }.not_to\
        yield_successive_args
    end
  end

  describe '.filter_hash!' do
    let(:keys) { [:key2, :key5] }
    let(:nested) { {key1: "v1", key2: {key3: "v2", key4: "v3"}, key5: "v4"} }
    let(:single) { {key1: "v1", key2: "v2", key5: "v3"} }

    it 'should correctly extract values for keys when single hash' do
      expect(helper.filter_hash!(keys, single)).to\
        eq({"key2" => "v2", "key5" => "v3"})
    end

    it 'should correctly extract values for keys when nested hash' do
      expect(helper.filter_hash!(keys, nested)).to\
        eq({"key2.key3" => "v2", "key2.key4" => "v3", "key5" => "v4"})
    end

    it 'should raise error when provided keys do not exist in hash' do
      expect{ helper.filter_hash!([:key2, :key6], nested) }.to\
        raise_error(ParameterMissingError)
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
