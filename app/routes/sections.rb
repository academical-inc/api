module Academical
  module Routes
    class Sections < Base

      include ModelRoutes

      post "/#{model_collection}/_bulk" do
        json_response update_resources
      end

    end
  end
end



