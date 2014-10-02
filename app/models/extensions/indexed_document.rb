module Academical
  module Models
    module IndexedDocument

      extend ActiveSupport::Concern

      module ClassMethods

        def unique_fields
          fields = []
          self.index_specifications.each do |spec|
            if spec.options[:unique] == true
              fields.concat spec.fields
            end
          end
          fields.uniq
        end

      end

    end
  end
end
