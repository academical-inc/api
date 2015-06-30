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
        query   = extract(:q)
        query   = "*" if query.blank?
        school  = extract(:school)
        term    = extract(:term)
        filters = extract(:filters)
        filters = MultiJson.load filters if not filters.blank?

        sections = Section.autocompl_search(query, school, term, filters)
        sections.each do |section|
          section.expand_events
          if section.corequisites.count > 0
            section.corequisites.each { |coreq| coreq.expand_events }
          end
        end
        json_response(sections, options: {properties: :public})
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



