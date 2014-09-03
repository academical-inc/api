module Academical
  module Models

    class AppUi

      include Mongoid::Document

      # Overriding _id since this will only be an embedded document
      field :_id, type: String, default: nil

      field :search_filters, type: Array, default: []
      field :summary_fields, type: Array, default: []
      field :search_result_fields, type: Array, default: []
      field :info_fields, type: Array, default: []

      embedded_in :school

    end

  end
end
