module Academical
  module Models
    module IndexedDocument

      extend ActiveSupport::Concern

      module ClassMethods

        def unique_fields
          fields = Set.new
          self.index_specifications.each do |spec|
            if spec.options[:unique] == true
              fields = fields.union spec.fields
            end
          end
          fields
        end

      end

    end
  end
end
