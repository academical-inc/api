require 'spec_helper'

describe Academical::Routes::Schools do

  to_update = {"name" => "Modified University" }
  to_remove = ["locale"]
  let(:resource_to_create) { build(:school) }

  it_behaves_like Academical::Routes::ModelRoutes, to_update, to_remove,
    School.linked_fields, []

end
