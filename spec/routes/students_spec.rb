require 'spec_helper'

describe Academical::Routes::Students do

  to_update = {"username" => "nidrog" }
  to_remove = ["email"]
  let(:resource_to_create) {
    s = create(:school)
    build(:student, school: s)
  }

  it_behaves_like Academical::Routes::ModelRoutes, to_update, to_remove,
    [:schedules], [:school, :registered_schedule]
end

