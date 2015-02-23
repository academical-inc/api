require 'spec_helper'

describe Academical::Routes::Schedules do

  to_update = {"name" => "Otha"}
  to_remove = ["total_credits"]
  let(:resource_to_create) {
    s = create(:school)
    student = create(:student, school: s)
    build(:schedule, school: s, student: student)
  }

  it_behaves_like Academical::Routes::ModelRoutes, to_update, to_remove,
    [:sections], [:school, :student], [:sections]
end


