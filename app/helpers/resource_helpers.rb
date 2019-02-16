#
# Copyright (C) 2012-2019 Academical Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

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
      rescue Mongo::Error::OperationFailure => ex
        raise Mongoid::Errors::DuplicateKey.new(
          ex, self.class.model.uniq_field_groups
        )
      end

      def update_resource(data=extract!(:data), id=extract!(:resource_id))
        data = remove_key :id, data
        r = resource id
        r.update_attributes! data
        r
      rescue Mongo::Error::OperationFailure => ex
        raise Mongoid::Errors::DuplicateKey.new(
          ex, self.class.model.uniq_field_groups
        )
      end

      def update_resources(data=extract!(:data))
        raise InvalidParameterError, :data if not data.is_a? Array
        count = 0
        data.each do |resource|
          begin
            update_resource resource, extract!(:id, resource)
            count += 1
          rescue Mongoid::Errors::DocumentNotFound
          end
        end
        if count < data.count
          raise Mongoid::Errors::DocumentsNotFound.new(
            count, data.count - count
          )
        end
        count
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

      def delete_resource(id=extract!(:resource_id))
        resource(id).destroy
      end

    end
  end
end
