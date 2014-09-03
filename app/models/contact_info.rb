module Academical
  module Models
    class ContactInfo

      include Mongoid::Document

      field :name, type: Hash, default: {}
      field :title
      field :phone

      embedded_in :school

    end
  end
end
