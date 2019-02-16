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
    class Teacher

      include Mongoid::Document
      include Mongoid::Timestamps
      include IndexedDocument
      include Linkable

      field :email, type: String
      field :title, type: String
      field :teacher_number, type: String
      embeds_one :name
      belongs_to :school, index: true
      has_and_belongs_to_many :sections, index: true

      validates_presence_of :name, :school
      before_save :reindex_sections

      index({:school => 1, "name.first" => 1, "name.middle" => 1,
             "name.last" => 1, "name.other" => 1}, {unique: true})

      def full_name
        name.full_name
      end

      def name_changed?
        name.first_changed? or name.last_changed? \
          or name.middle_changed? or name.other_changed?
      end

      # TODO Test
      def reindex_sections
        if name_changed?
          sections.each do |section|
            section.teacher_names = (section.teacher_names << self.full_name).uniq
            section.save
          end
        end
      end

      def self.linked_fields
        [:sections]
      end

    end
  end
end
