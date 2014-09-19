module Academical
  module Routes
    class Schools < Base

      helpers Helpers::SchoolHelpers

      get '/schools' do
        json schools
      end

      @base_school_route = '/schools/:school_id'
      get @base_school_route do
        json school
      end

      School.linked_fields.each do |field|
        get "#{@base_school_route}/#{field}" do
          json school.send(field.to_sym)
        end
      end

      post '/schools' do
        json create_school(params[:data])
      end

    end
  end
end
