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
  module Utils
    module ResponseUtils

      module_function

      def error_hash(prod, dev, ex: nil, message:nil, errors: [], data: nil)
        message = if not message.blank?
          message
        elsif not ex.blank? and not prod
          ex.message
        else
          "Something went wrong. Please try again later"
        end

        response_hash = {
          success: false,
          message: message,
          errors: errors
        }
        response_hash[:data] = data if not data.blank?
        response_hash[:backtrace] = ex.backtrace if dev and not ex.blank?

        response_hash
      end

      def success_hash(data, options=nil)
        is_hash = data.is_a? Hash
        contains_data_key = (is_hash and (data.key? :data or data.key? "data"))

        response_hash = if contains_data_key
          data.symbolize_keys
        else
          {data: data.as_json(options)}
        end

        response_hash.merge({success: true})
      end

    end
  end
end
