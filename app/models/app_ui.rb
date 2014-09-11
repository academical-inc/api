module Academical
  module Models

    class AppUi

      include Mongoid::Document

      field :search_filters, type: Hash, default: {}
      field :summary_fields, type: Hash, default: {}
      field :search_result_fields, type: Hash, default: {}
      field :info_fields, type: Array, default: []

      embedded_in :school

    end

  end
end
