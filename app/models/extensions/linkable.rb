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
  module Models
    module Linkable

      # USAGE:
      # Every Document Model that includes this module must implement
      # the class method .linked_fields
      # It must return fields which the model can respond to, and api endpoints
      # will be generated from these fields
      #
      # Examples:
      #
      #   class Model
      #     include Mongoid::Document
      #     include Linkable
      #
      #     field :field1
      #     field :unlinked_field1
      #
      #     def field2
      #       value
      #     end
      #
      #     def unlinked_field2
      #       value
      #     end
      #
      #     def self.linked_fields
      #       [:field1, :field2]
      #     end
      #   end
      #
      #   Model.new.respond_to? :field1 # => true
      #   Model.new.respond_to? :field2 # => true

      extend ActiveSupport::Concern

      included do
        field :links, type: Hash, default: {}
        before_create :update_links
      end

      def update_links
        base_url = link_to_self
        links[:self] = base_url
        self.class.linked_fields.each do |linked_field|
          links[linked_field] = "#{base_url}/#{linked_field}"
        end
      end

      def link_to_self
        class_name = self.class.name
        resource_url_name = class_name.demodulize.underscore.pluralize
        "/#{resource_url_name}/#{self._id}"
      end

      module ClassMethods

        module_function

        # Returns a list of fields the model responds to and which represent
        # links from the model which will be generated into API endpoints.
        # Refer to the documentation of this module for further explanation
        #
        # Example:
        #
        #   model.linked_fields
        #   # => [:field1, :field2]
        #
        def linked_fields
          raise MethodMissingError, "Must implement #linked_fields"
        end
      end

    end
  end
end
