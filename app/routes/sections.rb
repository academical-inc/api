module Academical
  module Routes
    class Sections < Base

      before "/sections*" do
        authorize! do
          is_admin?
        end
      end

      include ModelRoutes

    end
  end
end



