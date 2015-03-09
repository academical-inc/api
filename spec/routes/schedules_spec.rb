require 'spec_helper'

describe Academical::Routes::Schedules do

  to_update = {"name" => "Otha"}
  to_remove = ["name"]
  let(:resource_to_create) {
    s = create(:school)
    student = create(:student, school: s)
    student.schedules.each { |sched| sched.save! }
    build(:schedule, school: s, student: student)
  }

  it_behaves_like Academical::Routes::ModelRoutes, to_update, to_remove,
    [:sections, :events], [], [:sections]
end


