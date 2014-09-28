module Academical
  module Routes
    module ModelRoutes

      # USAGE
      # Every routes class that includes this module must inherit from Base and
      # be named as a plural of the Linkable model it wants to define routes
      # for.
      # If the routes class wants to be named differently, it must override the
      # class method .model and return the appropriate Linkable model class
      # associated with the routes.
      #
      # Assuming a model class named DummyModel, this module defines the
      # following routes for the model and performs the corresponding action
      # according to the semantics of http methods:
      #
      # - get /dummy_models
      # - get /dummy_models/:model_id
      # - get /dummy_models/:model_id/{linked_field} for every linked_field
      # - post /dummy_models
      # - put /dummy_models
      #
      # Examples:
      #
      # class DummyModel
      #   include Mongoid::Document
      #   include Linkable
      #
      #   field :field1
      #   def linked_fields
      #    [:field1]
      #   end
      # end
      #
      # class DummyModels < Base
      #   include ModelRoutes
      # end
      #

      extend ActiveSupport::Concern

      included do

        helpers model_helpers

        get "/#{model_collection}" do
          json_response send(self.class.model_collection)
        end

        get model_base_route do
          json_response send(self.class.model_singular)
        end

        model.linked_fields.each do |field|
          get "#{model_base_route}/#{field}" do
            json_response send(
              "#{self.class.model_singular}_rel".to_sym, field
            )
          end
        end

        post "/#{model_collection}" do
          json_response send(
            "create_#{self.class.model_singular}".to_sym
          ), code: 201
        end

        put "/#{model_collection}/?:#{model_singular}_id?" do
          res, code = send(
            "upsert_#{self.class.model_singular}".to_sym
          )
          json_response res, code: code
        end
      end

      module ClassMethods

        def model
          @model ||= self.name.demodulize.singularize.constantize
        rescue
          raise InvalidModelRouteError
        end

        def model_name
          @model_name ||= model.name.demodulize
        end

        def model_helpers
          @model_helpers ||= "#{model_name}Helpers".constantize
        end

        def model_collection
          @model_collection ||= model_name.underscore.pluralize.to_sym
        end

        def model_singular
          @model_singular ||= model_name.underscore.singularize.to_sym
        end

        def model_base_route
          @model_base_route ||= "/#{model_collection}/:#{model_singular}_id"
        end

      end

    end
  end
end
