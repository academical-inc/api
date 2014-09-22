require 'spec_helper'

describe ResponseUtils do
  let(:utls) { ResponseUtils }

  describe '.error_hash' do
    let(:ex) { StandardError.new "Test Error" }
    let(:msg) { "Test Message" }
    let(:gen_msg) { "Something went wrong. Please try again later" }
    let(:errors) { ["Error 1", "Error 2"] }

    it 'should indicate failure' do
      hash = utls.error_hash true, false
      expect(hash[:success]).to be(false)
    end

    it 'should always contain the provided message, if provided' do
      hash = utls.error_hash true, false, message: msg
      expect(hash[:message]).to eq(msg)
    end

    it 'should never contain backtrace if not in dev environment' do
      hash = utls.error_hash false, false
      expect(hash).not_to have_key(:backtrace)
      hash = utls.error_hash false, false, ex: ex
      expect(hash).not_to have_key(:backtrace)
    end

    context 'when in production environment' do

      it 'should show generic msg if no message provided' do
        hash = utls.error_hash true, false, ex: ex #even if exception provided
        expect(hash[:message]).to eq(gen_msg)
      end
    end

    context 'when not in production environment' do

      it 'should display backtrace if in dev env and exception provided' do
        hash = utls.error_hash false, true, ex: ex
        expect(hash).to have_key(:backtrace)
      end

      it 'should display generic message if no exception provided' do
        hash = utls.error_hash false, false
        expect(hash[:message]).to eq(gen_msg)
      end

      it 'should display exception message when exception provided' do
        hash = utls.error_hash false, false, ex: ex
        expect(hash[:message]).to eq(ex.message)
      end
    end
  end

  describe '.success_hash' do

    it 'should always indicate success' do
      data = {stuff: "stuff"}
      hash = utls.success_hash data
      expect(hash[:success]).to be(true)
    end

    context 'when data is iterable' do
      let(:data) {
        create_list(:student, 2)
        Student.all
      }

      it 'should return array with "data" root key' do
        hash = utls.success_hash data
        expect(hash).to have_key(:data)
      end

      it 'all elements of data should have "data" root key' do
        hash = utls.success_hash data
        hash[:data].each do |el|
          expect(el).to have_key(:data)
        end
      end
    end

    context 'when data is a hash' do
      let(:data) { {field1: "info1"} }

      it 'should always add "data" root key' do
        hash = utls.success_hash data
        expect(hash).to have_key(:data)
      end

      it 'should not add "data" root key if already present' do
        cor_data = {data: data}
        hash = utls.success_hash cor_data
        expect(hash).to have_key(:data)
        expect(hash[:data]).not_to have_key(:data)
        cor_data = {"data" => data}
        hash = utls.success_hash cor_data
        expect(hash).to have_key("data")
        expect(hash["data"]).not_to have_key(:data)
      end
    end

    context 'when data is not an iterable or a hash' do
      let(:data) {
        create(:student)
        Student.first
      }

      it 'should return a hash with the "data" root key' do
        hash = utls.success_hash data
        binding.pry
        expect(hash).to have_key(:data)
      end
    end
  end
end
