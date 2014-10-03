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

      it 'should return the correct school when using school nickname' do
        get "/schools/#{school.nickname}"
        expect_correct_model school.id
      end

      it 'should return 404 not found when school does not exist' do
        get "/schools/12345"
        expect_not_found_error
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

  context 'creation and updating' do
    let(:school) { build(:school) }
    let(:school_hash) {
      h = school.as_json
      h.except "id"
    }
    let(:modified) {
      modified = school_hash.dup
      modified["name"] = "The University"
      modified
    }
    let(:incomplete) { school_hash.except "locale" }
    let(:unknown) { {names: "others"} }
    let(:to_update) { {name: modified["name"]} }

    describe 'post /schools' do

      context 'when school does not exist' do

        it 'should create the school' do
          expect_model_to_be_created School do
            post_json '/schools', school_hash
          end
        end
      end

      context 'when a school with same values for uniq fields already exists' do

        it 'should update said school' do
          school.save!
          expect_model_to_be_updated School, school.id, to_update do
            post_json "/schools", modified
          end
        end
      end

      it 'should fail when payload does not have correct data key' do
        post_json '/schools', school_hash, root: false
        expect_missing_parameter_error
      end

      it 'should fail when school data is invalid' do
        post_json '/schools', school_hash.merge({name: nil})
      end

      it 'should fail when required school data is incomplete' do
        post_json '/schools', incomplete
        expect_validation_error
        post_json '/schools', modified.except("locale")
        expect_validation_error
      end

      it 'should fail when school data is unknown' do
        post_json '/schools', unknown
        expect_unknown_field_error
        post_json '/schools', modified.merge(unknown)
        expect_unknown_field_error
      end

    end

    describe 'put /schools/:school_id' do
      let(:update_path) { "/schools/#{school.id}" }

      it 'should fail if id not provided in url' do
        put_json '/schools', school_hash
        expect_invalid_path_error
      end

      it 'should fail if school does not exist' do
        put_json update_path, school_hash
        expect_not_found_error
      end

      context 'when school exists' do
        before(:each) do
          school.save!
        end

        it 'should update the school when entire resource provided' do
          expect_model_to_be_updated School, school.id, to_update do
            put_json update_path, modified
          end
        end

        it 'should update the school when specific fields provided' do
          expect_model_to_be_updated School, school.id, to_update do
            put_json update_path, to_update
          end
        end

        it\
        'should fail when data to update must be unique and already exists in the db'\
        do
          create(:school, name: "Rosario")
          put_json update_path, {name: "Rosario"}
          expect_duplicate_error School.unique_fields
        end

        it 'should fail when school data is invalid' do
          put_json update_path, {name: nil}
          expect_validation_error
        end

        it 'should fail when school data is unknown' do
          put_json update_path, unknown
          expect_unknown_field_error
        end

        it 'should fail when payload does not have correct data key' do
          put_json update_path, school_hash, root: false
          expect_missing_parameter_error
        end
      end


    end
  end
end
