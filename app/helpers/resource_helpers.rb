module Academical
  module Helpers
    module ResourceHelpers

      module_function

      def resources(where: nil, count: contains?(:count))
        res = self.class.model.where(where)
        get_result(res, count)
      end

      def resource(id=extract!(:resource_id))
        self.class.model.find(id)
      end

      def resource_rel(field, id: extract!(:resource_id),
                       count: contains?(:count))
          res = resource(id).send(field.to_sym)
          get_result(res, count)
      end

      def create_resource(data=extract!(:data))
        self.class.model.create! data
      end

      def upsert_resource(data=extract!(:data), id=extract(:resource_id))
        id ||= data["id"]
        if self.class.model.where(id: id).exists?
          r = resource(id)
          r.update_attributes! data
          [r, 200]
        else
          [create_resource(data), 201]
        end
      end

    end
  end
end
