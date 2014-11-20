require 'spec_helper'

describe Academical::Routes::Sections do

  to_update = {"course_name" => "Modified Course Name" }
  to_remove = ["credits"]

  except_for_create = ["teacher_names"]
  let(:resource_to_create) {
    s = create(:school)
    build(:section, :with_teachers, school: s)
  }

  it_behaves_like Academical::Routes::ModelRoutes, to_update, to_remove,
    [:teachers, :schedules], [:school], except_for_create


  describe "put /sections/_bulk" do
    let(:sections) { create_list(:section, 3) }
    let!(:secs_to_update) {
      sections.map do |section|
        s = section.seats
        {
          "id" => section.id,
          "seats" => {
            "available" => s[:available] + 1,
            "taken" => s[:taken]-1,
            "total" => s[:total]
          }
        }
      end
    }

    it 'should update all sections provided in request' do
      expect_models_to_be_updated Section, secs_to_update do
        post_json "/sections/_bulk", secs_to_update
      end
    end

    it 'should fail if data parameter is not an array' do
      post_json "/sections/_bulk", secs_to_update.first
      expect_invalid_parameter_error
    end

    it 'should fail if any of the provided sections does not exist' do
      secs_to_update.first["id"] = "non_existent"
      real_update = secs_to_update[1..-1]
      expect_models_partially_updated Section, real_update, 3 do
        post_json "/sections/_bulk", secs_to_update
      end
    end
  end

  # TODO Test #students behavior
  # TODO Test expand sections behavior

end

