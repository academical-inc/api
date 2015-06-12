require 'spec_helper'

describe Academical::Routes::Sections do

  to_update = {"course_name" => "Modified Course Name" }
  to_remove = ["credits"]

  except_for_create = ["teacher_names"]
  before(:each) { make_admin true }
  let(:resource_to_create) {
    s = create(:school)
    build(:section, :with_teachers, school: s)
  }

  it_behaves_like Academical::Routes::ModelRoutes, to_update, to_remove,
    [:teachers, :schedules], [], except_for_create

  # TODO Test #students behavior
  # TODO Test expand sections behavior

end

