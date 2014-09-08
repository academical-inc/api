module Academical
  module Models
    module Linkable

      def self.included(receiver)
        receiver.class_eval do
          field :links, type: Hash, default: {}
          before_create :update_links
        end
      end

      def update_links
        base_url = link_to_self
        links[:self] = base_url
        linked_fields.each do |linked_field|
          links[linked_field] = "#{base_url}/#{linked_field}"
        end
      end

      def linked_fields
        raise MethodMissingError, "Must implement #linked_fields"
      end

      def link_to_self
        class_name = self.class.name
        resource_url_name = class_name.demodulize.underscore.pluralize
        "/#{resource_url_name}/#{self._id}"
      end

    end
  end
end
