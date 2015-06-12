module Academical
  module Routes
    class Teachers < Base

      before "/teachers*" do
        authorize! do
          is_admin?
        end
      end

      include ModelRoutes

    end
  end
end

