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

  context 'creation and update' do
    let(:school) { build(:school) }
    let(:school_hash) {
      h = school.as_json
      h.delete("id")
      h
    }
    let(:incomplete) {
      s = school_hash.dup
      s.delete("name")
      {data: s}.to_json
    }
    let(:unknown) { {data: {names: "others"}}.to_json }
    let(:payload) { {data: school_hash}.to_json }

    describe 'post /schools' do

      it 'should create the school' do
        expect_model_to_be_created School do
          post_json '/schools', payload
        end
      end

      it 'should fail when payload does not have correct data key' do
        post_json '/schools', school_hash.to_json
        expect_missing_parameter_error
      end

      it 'should fail when required school data is incomplete' do
        post_json '/schools', incomplete
        expect_validation_error
      end

      it 'should fail when school data is unknown' do
        post_json '/schools', unknown
        expect_unknown_field_error
      end

    end

    describe 'put /schools' do

      it 'should fail when payload does not have correct data key' do
        put_json '/schools', school_hash.to_json
        expect_missing_parameter_error
      end

      context 'when school does not exist' do

        it 'should create the school' do
          expect_model_to_be_created School do
            put_json '/schools', payload
          end
        end

        it 'should fail when required school data is incomplete' do
          put_json '/schools', incomplete
          expect_validation_error
        end

        it 'should fail when school data is unknown' do
          put_json '/schools', unknown
          expect_unknown_field_error
        end
      end

      context 'when school already exists' do
        before(:each) do
          school.save!
        end
        let!(:modified) {
          modified = school_hash.dup
          modified["name"] = "The University"
          modified
        }
        let(:to_update) { {name: modified["name"]} }

        it 'should update the school when specifying id in url' do
          expect_model_to_be_updated School, school.id, to_update do
            put_json "/schools/#{school.id}", {data: modified}.to_json
          end
        end

        it 'should update the school when specifying id in json body' do
          modified["id"] = school.id.to_s
          expect_model_to_be_updated School, school.id, to_update do
            put_json '/schools', {data: modified}.to_json
          end
        end

        it\
        'should update the school when only providing fields to update and id in url'\
        do
          expect_model_to_be_updated School, school.id, to_update do
            put_json "/schools/#{school.id}", {data: to_update}.to_json
          end
        end

        it\
        'should update the school when only providing fields to update and id in body'\
        do
          expect_model_to_be_updated School, school.id, to_update do
            put_json '/schools', {data: to_update.merge(id: school.id.to_s)}\
              .to_json
          end
        end

      end
    end
  end
end
