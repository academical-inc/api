module Academical
  module Models
    class ContactInfo

      include Mongoid::Document

      # Overriding _id since this will only be an embedded document
      field :_id, type: String, default: nil

      field :name, type: Hash, default: {}
      field :title
      field :phone

      embedded_in :school

    end
  end
end
