module Academical
  module Routes
    class Schools < Base

      include ModelRoutes

      def resource(id=extract!(:resource_id))
        self.class.model.find_by({nickname: id})
      rescue
        super(id)
      end

    end
  end
end
