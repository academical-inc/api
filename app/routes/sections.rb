module Academical
  module Routes
    class Sections < Base

      configure do
        set :search_expiration, ENV['MEMCACHE_EXPIRES_SEARCH'].to_i.minutes
      end

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

        qs         = "-search-#{request.env["rack.request.query_string"]}"
        cache      = settings.cache
        expires_in = settings.search_expiration

        res = cache.fetch(qs, expires_in: expires_in) do
          query   = extract(:q)
          query   = "*" if query.blank?
          school  = extract(:school)
          term    = extract(:term)
          filters = extract(:filters)
          filters ||= []
          filters = MultiJson.load filters if not filters.blank?

          Section.autocompl_search(query, school, term, filters).as_json(
            properties: :public
          )
        end

        json_response res
      end

      post "/sections" do
        clean_hash_default_proc!
        res, code = upsert_resource
        # TODO Hackish, fix and test
        # https://github.com/mongoid/mongoid/issues/3611
        res.events.each { |ev| ev.save! }
        json_response res, options: {properties: :all}, code: code
      end

      include ModelRoutes

    end
  end
end



