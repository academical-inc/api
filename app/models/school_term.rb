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
    class SchoolTerm

      include Mongoid::Document

      field :name, type: String
      field :start_date, type: Date
      field :end_date, type: Date

      validates_presence_of :name, :start_date, :end_date
      validate :dates_are_correct

      embedded_in :school, inverse_of: :terms

      def dates_are_correct
        if start_date.blank?
          errors.add(:start_date, "can't be blank")
        elsif end_date.blank?
          errors.add(:end_date, "can't be blank")
        else
          errors.add(:start_date, "can't be greater than or equal to end_date") \
            if start_date >= end_date
        end
      end

    end
  end
end
