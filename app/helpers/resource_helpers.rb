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
        get_result res, count
      end

      def resource(id=extract!(:resource_id))
        self.class.model.find id
      end

      def resource_by(query)
        self.class.model.find_by query
      end

      def resource_first_match(queries)
        ex = nil
        queries.each do |query|
          begin
            return resource_by query
          rescue Mongoid::Errors::DocumentNotFound => e
            ex = e
          end
        end
        raise ex
      end

      def resource_rel(field, id: extract!(:resource_id),
                       count: contains?(:count))
          res = resource(id).send field.to_sym
          get_result res, count
      end

      def create_resource(data=extract!(:data))
        data = remove_key :id, data
        self.class.model.create! data
      rescue Moped::Errors::OperationFailure => ex
        raise Mongoid::Errors::DuplicateKey.new(
          ex, self.class.model.uniq_field_groups
        )
      end

      def update_resource(data=extract!(:data), id=extract!(:resource_id))
        data = remove_key :id, data
        r = resource id
        r.update_attributes! data
        r
      rescue Moped::Errors::OperationFailure => ex
        raise Mongoid::Errors::DuplicateKey.new(
          ex, self.class.model.uniq_field_groups
        )
      end

      def upsert_resource(data=extract!(:data))
        data = remove_key :id, data
        begin
          [create_resource(data), 201]
        rescue Mongoid::Errors::DuplicateKey => ex
          queries = ex.uniq_field_groups.map do |group|
            extract_all! group, data
          end

          # This query should never fail because we already know that a single
          # document with those fields already exists in the database.
          r = resource_first_match queries
          r.update_attributes! data
          [r, 200]
        end
      end

    end
  end
end
