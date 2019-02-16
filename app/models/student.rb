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
    class Student

      MAX_SCHEDULES = 7

      include Mongoid::Document
      include Mongoid::Timestamps
      include IndexedDocument
      include Linkable

      field :name, type: String
      field :auth0_user_id, type: String
      field :email, type:String
      field :student_number, type: String
      field :picture, type: String,
                      default: -> { Student.default_picture(email) }

      belongs_to :school, index: true
      belongs_to :registered_schedule, class_name: "Schedule", inverse_of: nil
      has_many   :schedules, order: :created_at.asc, dependent: :destroy do
        # TODO Test
        def latest
          term = @base.school.terms.latest.name
          @target.select { |schedule| schedule.term == term }
        end
      end

      index({auth0_user_id: 1}, {unique: true, name: "auth0_user_id_index"})
      index({email: 1}, {name: "email_index"})

      validates_presence_of :auth0_user_id, :email, :school
      validates_format_of :email, :with => /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/
      validate :schedules_within_limit

      after_create :create_default_schedule

      def create_default_schedule
        if schedules.empty?
          Schedule.create!(
            name: I18n.t("schedule.default_name", locale: school.locale),
            student: self,
            school: school,
            term: school.terms.latest.name
          )
        end
      end

      def schedules_within_limit
        if schedules.latest.count > MAX_SCHEDULES
          errors.add("schedules",
                     "number for current term should not exceed #{MAX_SCHEDULES}")
        end
      end

      def has_section?(sec_id)
        self.schedules.each do |schedule|
          return true if schedule.section_ids.include? sec_id
        end
        false
      end

      def self.linked_fields
        [:schedules, :registered_schedule]
      end

      def self.default_picture(email = nil)
        md5 = ''
        md5 = Digest::MD5.hexdigest email unless email.nil?
        "https://s.gravatar.com/avatar/#{md5}?s=480&r=pg&d=mm"
      end
    end
  end
end
