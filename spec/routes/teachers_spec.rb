require 'spec_helper'

describe Academical::Routes::Teachers do

  to_update = {"email" => "mod@email.co" }
  to_remove = ["name"]
  let(:resource_to_create) {
    s = create(:school)
    build(:teacher, school: s)
  }

  it_behaves_like Academical::Routes::ModelRoutes, to_update, to_remove,
    [:sections], []
end


