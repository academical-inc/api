module Academical
  module Routes
    class Schools < Base

      helpers SchoolHelpers

      get '/schools' do
        json_response schools
      end

      @base_school_route = '/schools/:school_id'
      get @base_school_route do
        json_response school
      end

      School.linked_fields.each do |field|
        get "#{@base_school_route}/#{field}" do
          json_response school.send(field.to_sym)
        end
      end

      post '/schools' do
        json_response create_school, code: 201
      end

    end
  end
end
