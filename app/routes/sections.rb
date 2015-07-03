module Academical
  module Routes
    class Sections < Base

      before "/sections*" do
        pass if request.get? and request.path_info == "/sections/search"
        authorize! do
          is_admin?
        end
      end

      get "/sections/search" do
        authorize! do
          is_admin? or is_student?
        end
        qs = "-search-#{request.env["rack.request.query_string"]}"
        json_response settings.cache.fetch(qs) do
          query   = extract(:q)
          query   = "*" if query.blank?
          school  = extract(:school)
          term    = extract(:term)
          filters = extract(:filters)
          filters ||= []
          filters = MultiJson.load filters if not filters.blank?

          Section.autocompl_search(query, school, term, filters).as_json(
            options: {properties: :public}
          )
        end
      end

      post "/sections" do
        clean_hash_default_proc!
        res, code = upsert_resource
        json_response res, options: {properties: :all}, code: code
      end

      include ModelRoutes

    end
  end
end



