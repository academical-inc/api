require 'spec_helper'

describe Academical::Routes::Sections do

  to_update = {"course_name" => "Modified Course Name" }
  to_remove = ["credits"]
  let(:resource_to_create) {
    s = create(:school)
    build(:section, :with_teachers, school: s)
  }

  it_behaves_like Academical::Routes::ModelRoutes, to_update, to_remove,
    [:teachers, :schedules], [:school]

  # TODO Test #students behavior
  # TODO Test expand sections behavior

end

