module Academical
  module Models
    module IndexedDocument

      extend ActiveSupport::Concern

      module ClassMethods

        def unique_fields
          fields = []
          self.index_specifications.each do |spec|
            if spec.options[:unique] == true
              vals = spec.fields.map { |f| f.to_s.split(".").first.to_sym }
              fields.concat vals
            end
          end
          fields.uniq
        end

      end

    end
  end
end
