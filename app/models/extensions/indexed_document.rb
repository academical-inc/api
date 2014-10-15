module Academical
  module Models
    module IndexedDocument

      extend ActiveSupport::Concern

      module ClassMethods

        def uniq_field_groups
          fields = []
          self.index_specifications.each do |spec|
            if spec.options[:unique] == true
              fields << spec.fields
            end
          end
          fields.uniq
        end

      end

    end
  end
end
