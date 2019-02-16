#
# Copyright (C) 2012-2019 Academical Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

module Academical
  module Routes
    class Sections < Base

      def search
        query   = extract(:q)
        query   = "*" if query.blank?
        school  = extract(:school)
        term    = extract(:term)
        filters = extract(:filters)
        filters ||= []
        filters = MultiJson.load filters if not filters.blank?

        Section.autocompl_search(query, school, term, filters).as_json(
          properties: :public,
          version: "v#{school}".to_sym
        )
      end

      configure do
        set :search_expiration, ENV['MEMCACHE_EXPIRES_SEARCH'].to_i.minutes
        set :disable_search_caching, ENV['DISABLE_SEARCH_CACHING'] == 'true'
      end

      before "/sections*" do
        pass if request.get? and request.path_info == "/sections/search"
        authorize! do
          is_admin?
        end
      end

      get "/sections/search/?" do
        authorize! do
          is_admin? or is_student?
        end

        res = if settings.disable_search_caching
          search
        else
          qs         = "-search-#{request.env["rack.request.query_string"]}"
          cache      = settings.cache
          expires_in = settings.search_expiration
          cache.fetch(qs, expires_in: expires_in) { search }
        end

        json_response res
      end

      post "/sections/?" do
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



