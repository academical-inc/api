require 'spec_helper'

describe Academical::Routes::Schools do

  describe 'get /schools' do

    context 'when schools present' do
      let!(:andes) { create(:school) }
      let!(:rosario) { create(:school, name: "Rosario") }

      it 'should return the list of schools' do
        get '/schools'
        expect_correct_models [andes.id, rosario.id]
      end

      it 'should return the number of schools when count requested' do
        get '/schools?count'
        expect(json_response).to eq(2)
      end
    end

    context 'when no schools present' do

      it 'should return an empty list' do
        get '/schools'
        expect_collection 0
      end

      it 'should return 0 when count requested' do
        get '/schools?count'
        expect(json_response).to eq(0)
      end
    end
  end

  context 'single school' do
    let!(:school) { create(:school) }
    let(:base_url) { "/schools/#{school.id}" }

    describe "get /schools/:school_id" do

      it 'should return the correct school' do
        get "/schools/#{school.id}"
        expect_correct_model school.id
      end

      it 'should return 404 not found when school does not exist' do
        get "/schools/12345"
        expect_not_found
      end

    end

    context 'school relations' do

      School.linked_fields.each do |field|
        context "when school field #{field} is not present" do

          describe "get /schools/:school_id/#{field}" do
            it "should return an empty list" do
              get "/schools/#{school.id}/#{field}"
              expect_collection 0
            end

            it "should return 0 when count requested" do
              get "/schools/#{school.id}/#{field}?count"
              expect(json_response).to eq(0)
            end
          end
        end

        context "when school field #{field} is present" do

          describe "get /schools/:school_id/#{field}" do
            before(:each) do
              factory = field.to_s.singularize.to_sym
              create_list(factory, 5, school: school)
            end
            let!(:ids) {
              school.send(field).collect do |linked_model|
                linked_model.id
              end
            }

            it "should return the school's #{field}" do
              get "/schools/#{school.id}/#{field}"
              expect_correct_models ids
            end

            it "should return the number of #{field} when count requested" do
              get "/schools/#{school.id}/#{field}?count"
              expect(json_response).to eq(5)
            end
          end
        end
      end
    end
  end

  describe 'post /schools' do
    let(:school) { build(:school) }
    let(:school_hash) { school.as_json }
    let(:payload) { {data: school_hash}.to_json }

    it 'should create the school' do
      expect_model_to_be_created School, school.id do
        post_json '/schools', payload
      end
    end

    it 'should fail when payload does not have correct data key' do
      post_json '/schools', school_hash.to_json
      expect_missing_parameter_error
    end

    it 'should fail when required school data is incomplete' do
      incomplete = {data: school_hash.dup.delete(:name)}.to_json
      post_json '/schools', incomplete
      expect_validation_error
    end

    it 'should fail when school data is unknown' do
      post_json '/schools', {data: {names: "others"}}.to_json
      expect_unknown_field_error
    end

  end

  describe 'put /schools' do

    it 'should create the school if it does not exist' do

    end

    it 'shuld update the school if it already exists' do

    end

    it 'should fail if school data is invalid' do

    end

    it 'should fail if school data is incomplete or unknown' do

    end

  end

end
