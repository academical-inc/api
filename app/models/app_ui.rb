module Academical
  module Models

    class AppUi

      include Mongoid::Document

      field :search_filters, type: Array, default: []
      field :summary_fields, type: Array, default: []
      field :search_result_fields, type: Hash, default: {}
      field :info_fields, type: Hash, default: {}

      embedded_in :school

    end

  end
end
