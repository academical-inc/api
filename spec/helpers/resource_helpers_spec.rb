require 'spec_helper'

describe ResourceHelpers do


  # TODO Test with every model
  # This is complicated because of relations particular to every model
  # Still, this behavior is tested when testing the endpoints.
  it_behaves_like "resource_helpers_for", School

end
