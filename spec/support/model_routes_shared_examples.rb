
shared_examples_for Academical::Routes::ModelRoutes\
do |to_update, to_remove, linked_fields_many, linked_fields_single|

  base_path = "/#{described_class.model_collection}"
  factory = described_class.model_singular
  model = described_class.model

  describe "get #{base_path}" do

    context 'when resources are present' do
      let!(:res_list) { create_list(factory, 2) }

      it 'should return the list of resources' do
        get base_path
        expect_correct_models(res_list.collect { |r| r.id })
      end

      it 'should return the number of resources when count requested' do
        get "#{base_path}?count"
        expect(json_response).to eq(2)
      end
    end

    context 'when no resources present' do

      it 'should return an empty list' do
        get base_path
        expect_collection 0
      end

      it 'should return 0 when count requested' do
        get "#{base_path}?count"
        expect(json_response).to eq(0)
      end
    end
  end

  context 'single resource' do
    let!(:resource_created) { create(factory) }
    let(:single_path) { "#{base_path}/#{resource_created.id}" }

    describe "get #{base_path}/:resource_id" do

      it 'should return the correct resource' do
        get single_path
        expect_correct_model resource_created.id
      end

      it 'should fail when resource does not exist' do
        get "#{base_path}/non_existent"
        expect_not_found_error
      end
    end

    context 'resource relations' do

      linked_fields_single.each do |field|

        describe "get #{base_path}/:resource_id/#{field}" do
          let(:rel_path) { "#{single_path}/#{field}" }
          let!(:field_factory) { get_factory_for model, field }

          context "when resource's #{field} is not present" do
            before(:each) do
              resource_created.send(field).destroy!\
                if not resource_created.send(field).nil?
            end

            it 'should return nil' do
              get rel_path
              expect_nil
            end

            it 'should return 0 when count requested' do
              get "#{rel_path}?count"
              expect(json_response).to eq(0)
            end
          end

          context "when resource's #{field} is present" do
            before(:each) do
              resource_created.send "#{field}=".to_sym, create(field_factory)
              resource_created.save!
            end

            it "should return the correct #{field}" do
              get rel_path
              expect_correct_model resource_created.send(field).id
            end

            it 'should return 1 when count requested' do
              get "#{rel_path}?count"
              expect(json_response).to eq(1)
            end
          end
        end
      end


      linked_fields_many.each do |field|

        describe "get #{base_path}/:resource_id/#{field}" do
          let(:rel_path) { "#{single_path}/#{field}" }
          let!(:field_factory) { get_factory_for model, field }

          context "when resource field #{field} is not present" do
            before(:each) do
              resource_created.send("#{field}=".to_sym, [])
            end

            it 'should return an empty list' do
              get rel_path
              expect_collection 0
            end

            it 'should return 0 when count requested' do
              get "#{rel_path}?count"
              expect(json_response).to eq(0)
            end
          end

          context "when resource field #{field} is present" do
            before(:each) do
              vals = create_list(field_factory, 2)
              resource_created.send("#{field}=".to_sym, vals)
              resource_created.save!
            end
            let!(:ids) { resource_created.send(field).
                         collect { |linked| linked.id } }

            it "should return the resource's #{field}" do
              get rel_path
              expect_correct_models ids
            end

            it "should return the number of #{field} when count requested" do
              get "#{rel_path}?count"
              expect(json_response).to eq(2)
            end
          end
        end
      end
    end

    describe "delete #{base_path}/:resource_id" do

      it 'should delete the resource correctly' do
        expect_model_to_be_deleted model, resource_created.id do
          delete single_path
        end
      end

      it 'should fail when resource does not exist' do
        delete "#{base_path}/non_existent"
        expect_not_found_error
      end

      it 'should fail when id not provided in url' do
        delete base_path
        expect_invalid_path_error
      end
    end
  end

  context 'creating and updating' do
    let(:res_hash) { resource_to_create.as_json.except "id" }
    let(:modified) {
      m = res_hash.dup
      to_update.each_pair do |key, val|
        m[key] = val
      end
      m
    }
    let(:invalid) {
      inv = res_hash.dup
      to_remove.each do |f|
        inv[f.to_s] = nil
      end
      inv
    }
    let(:incomplete) {
      if to_remove.is_a? Enumerable
        res_hash.except(*to_remove)
      else
        to_remove.call res_hash
      end
    }
    let(:unknown) { {unknown: "data"} }

    describe "post #{base_path}" do

      context 'when resource does not exist' do

        it 'should create the resource' do
          expect_model_to_be_created model do
            post_json base_path, res_hash
          end
        end
      end

      if not model.uniq_field_groups.blank?
      context 'when resource with same values for uniq fields already exists' do

        it 'should update said resource when it is the only one in the db' do
          resource_to_create.save!
          expect_model_to_be_updated model, resource_to_create.id, to_update do
            post_json base_path, modified
          end
        end

        it 'should update said resource when it is not the only one in the db' do
          create(factory)
          resource_to_create.save!
          expect_model_to_be_updated model, resource_to_create.id, to_update do
            post_json base_path, modified
          end
        end
      end
      end

      it 'should fail when payload does not have correct data key' do
        post_json base_path, res_hash, root: false
        expect_missing_parameter_error
      end

      it 'should fail when resource data is invalid' do
        post_json base_path, invalid
        expect_validation_error
      end

      it 'should fail when required resource data is incomplete' do
        post_json base_path, incomplete
        expect_validation_error
        post_json base_path, modified.except(*to_remove)
        expect_validation_error
      end

      it 'should fail when school data is unknown' do
        post_json base_path, unknown
        expect_unknown_field_error unknown.keys.first
        post_json base_path, modified.merge(unknown)
        expect_unknown_field_error unknown.keys.first
      end
    end

    describe "put #{base_path}/:resource_id" do
      let(:update_path) { "#{base_path}/#{resource_to_create.id}" }

      it 'should fail if id not provided in url'do
        put_json base_path, res_hash
        expect_invalid_path_error
      end

      it 'should fail if resource does not exist' do
        put_json update_path, res_hash
        expect_not_found_error
      end

      context 'when resource exists' do
        before(:each) do
          resource_to_create.save!
        end

        it 'should update the resource when entire resource provided' do
          expect_model_to_be_updated model, resource_to_create.id, to_update do
            put_json update_path, modified
          end
        end

        it 'should update the resource when specific fields provided' do
          expect_model_to_be_updated model, resource_to_create.id, to_update do
            put_json update_path, to_update
          end
        end

        if not model.uniq_field_groups.blank?
        it 'should fail when data to update already exists in the collection' do
          other_res = create(factory)
          put_json update_path, other_res.as_json.except("id")
          expect_duplicate_error model.uniq_field_groups
        end
        end

        it 'should fail when resource data is invalid' do
          put_json update_path, invalid
          expect_validation_error
        end

        it 'should fail when resource data is unknown' do
          put_json update_path, unknown
          expect_unknown_field_error unknown.keys.first
        end

        it 'should fail when payload does not have correct data key' do
          put_json update_path, res_hash, root: false
          expect_missing_parameter_error
        end
      end
    end

  end

end
