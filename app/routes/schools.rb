module Academical
  module Routes
    class Schools < Base

      before "/schools*" do
        authorize! do
          is_admin?
        end
      end

      include ModelRoutes

      def resource(id=extract!(:resource_id))
        self.class.model.find_by({nickname: id})
      rescue
        super(id)
      end

    end
  end
end
