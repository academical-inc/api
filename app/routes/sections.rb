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
        # authorize! do
        #   is_admin? or is_student?
        # end
        query   = extract(:q) || "*"
        school  = extract(:school)
        term    = extract(:term)
        filters = extract(:filters)
        filters = MultiJson.load filters if not filters.blank?

        json_response Section.autocompl_search(query, school, term, filters )
      end

      include ModelRoutes

    end
  end
end



