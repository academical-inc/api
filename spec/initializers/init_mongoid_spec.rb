require 'spec_helper'

describe 'Mongoid Initializer' do

  describe Mongoid::Errors::DuplicateKey do

    describe '#initialize' do
      let(:dup_key_er) {
        se = StandardError.new
        allow(se).to receive(:details) { {'code' => 11000} }
        se
      }
      let(:not_dup_key_er) {
        se = StandardError.new
        allow(se).to receive(:details) { {'code' => 22000} }
        se
      }
      let(:se) { StandardError.new }

      it 'should initialize the exception correctly' do
        begin
          e = Mongoid::Errors::DuplicateKey.new(dup_key_er, [:field1])
          raise e
        rescue Mongoid::Errors::DuplicateKey => ex
          expect(ex).to be
          expect(ex.uniq_field_groups).to eq([:field1])
          expect(ex.message).to\
            eq("A resource with the unique fields #{[:field1]} already exists")
        end
      end

      it\
      'should raise error when the passed exception is not a DuplicateKey error'\
      do
        expect{ Mongoid::Errors::DuplicateKey.new(not_dup_key_er) }.to\
          raise_error
        expect{ Mongoid::Errors::DuplicateKey.new(se) }.to raise_error
      end
    end

  end

end
