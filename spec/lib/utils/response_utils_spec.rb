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

    it 'should always contain a "data" root key' do
      create_list(:student, 2)
      [ {a: "a"},
        {"data"=>"a"},
        5,
        "informationz!",
        [9, 9],
        nil,
        Student.first,
        Student.all
      ].each do |el|
        hash = utls.success_hash(el)
        expect(hash).to have_key(:data)
      end
    end

    context 'when data is iterable of models' do
      let(:data) {
        create_list(:student, 2)
        Student.all
      }

      it 'all elements of data should have "data" root key' do
        hash = utls.success_hash data
        hash[:data].each do |el|
          expect(el).to have_key(:data)
        end
      end
    end

    context 'when data is a hash' do
      let(:data) { {field1: "info1"} }

      it 'should not add "data" root key if already present' do
        [ {data: data}, {"data" => data} ].each do |hash_data|
          hash = utls.success_hash hash_data
          expect(hash).to have_key(:data)
          expect(hash[:data]).not_to have_key(:data)
          expect(hash[:data]).not_to have_key("data")
        end
      end
    end

  end
end
