module Academical
  module Helpers
    module ResourceHelpers

      # USAGE:
      # *You should not include this module directly*
      # This module is intended to be added to Sinatra Helpers via the helpers
      # function by the module 'ModelRoutes', and assumes the existance of the
      # class method .model
      # 'ModelRoutes' is included by Routes classes for a specific model.
      # Refer to the documentation for 'ModelRoutes' for further reference.

      module_function

      def resources(where: nil, count: contains?(:count))
        res = self.class.model.where(where)
        get_result(res, count)
      end

      def resource(id=extract!(:resource_id))
        self.class.model.find(id)
      end

      def resource_like(query)
        begin
          self.class.model.find_by query
        rescue Mongoid::Errors::DocumentNotFound
          r =  nil
          query.each do |k, v|
            begin
              r = self.class.model.find_by({k=>v})
              break
            rescue Mongoid::Errors::DocumentNotFound
            end
          end
          r
        end
      end

      def resource_rel(field, id: extract!(:resource_id),
                       count: contains?(:count))
          res = resource(id).send(field.to_sym)
          get_result(res, count)
      end

      def create_resource(data=extract!(:data))
        self.class.model.create! data
      rescue Moped::Errors::OperationFailure => ex
        raise Mongoid::Errors::DuplicateKey.new(
          ex, self.class.model.unique_fields
        )
      end

      def update_resource(data=extract!(:data), id=extract!(:resource_id))
        r = resource(id)
        r.update_attributes! data
        r
      rescue Moped::Errors::OperationFailure => ex
        raise Mongoid::Errors::DuplicateKey.new(
          ex, self.class.model.unique_fields
        )
      end

      def upsert_resource(data=extract!(:data))
        remove_key(:id, data)

        begin
          [create_resource(data), 201]
        rescue Mongoid::Errors::DuplicateKey => ex
          query = filter_hash! ex.fields, data

          # This query should never fail because we already know that a single
          # document with those fields already exists in the database.
          r = resource_like query
          r.update_attributes! data
          [r, 200]
        end
      end

    end
  end
end
