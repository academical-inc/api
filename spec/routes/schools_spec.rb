require 'spec_helper'

describe Academical::Routes::Schools do

  def post_json(*args)
    post(*args, { 'CONTENT_TYPE' => 'application/json',
                  'ACCEPT' => 'application/json' })
  end

  describe 'get /schools' do

    it 'should return the list of schools' do
      create(:school)
      get '/schools'
      expect(last_response).to be_ok
    end
  end

  describe 'post /schools' do
    let(:school) { build(:school) }
    let(:school_hash) { school.as_json }
    let(:payload) { {data: school_hash}.to_json }

    it 'should create the school' do
      expect{
        post_json '/schools', payload
      }.to change(School, :count).by(1)
      expect(last_response.status).to eq 201
    end
  end

end
