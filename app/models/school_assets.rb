module Academical
  module Models
    class SchoolAssets

      include Mongoid::Document

      # Overriding _id since this will only be an embedded document
      field :_id, type: String, default: nil

      field :logo_url

      embedded_in :school, inverse_of: :assets

      validates_presence_of :logo_url

    end
  end
end
