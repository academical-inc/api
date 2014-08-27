module Academical
  module Models

    class SchoolAssets

      include Mongoid::Document

      field :logo_url

      validates_presence_of :logo_url

      embedded_in :school, inverse_of: :assets

    end
  end
end
