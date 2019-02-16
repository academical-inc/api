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
  module Models
    class Name

      include Mongoid::Document
      include CommonHelpers

      field :first, type: String
      field :middle, type: String, default: ""
      field :last, type: String
      field :other, type: String, default: ""

      embedded_in :student
      embedded_in :teacher

      validates_presence_of :first, :last

      def full_name(include_other: false, truncate: true, trunc_length: 35)
        full_name = first.dup
        full_name << " #{middle}" if not middle.blank?
        full_name << " #{last}"
        full_name << " #{other}" if include_other and not other.blank?
        full_name = full_name.truncate(trunc_length) if truncate
        titleize full_name
      end

      def titleize_name
        self.first  = titleize first
        self.last   = titleize last
        self.middle = titleize middle if not middle.blank?
        self.other  = titleize other if not other.blank?
      end

    end
  end
end
