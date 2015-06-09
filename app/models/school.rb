module Academical
  module Models
    class School

      include Mongoid::Document
      include Mongoid::Timestamps
      include IndexedDocument
      include Linkable

      field :name, type: String
      field :nickname, type: String
      field :locale, type: String
      field :custom, type: Hash
      field :active_modules, type: Array
      field :urls, type: Hash
      field :timezone, type: String
      field :utc_offset, type: Integer
      field :identity_providers, type: Array
      embeds_one :contact_info
      embeds_one :location
      embeds_one :assets, class_name: "SchoolAssets"
      embeds_one :app_ui
      embeds_many :departments
      embeds_many :terms, class_name: "SchoolTerm", order: :start_date.desc  do
        def latest_term
          desc(:start_date).limit(1).first
        end
      end
      has_many :teachers
      has_many :students
      has_many :sections
      has_many :schedules

      index({name: 1}, {unique: true})
      index({nickname: 1}, {unique: true})

      before_save :set_utc_offset

      validates_presence_of :name, :nickname, :locale, :departments, :terms,
                            :assets, :app_ui, :timezone, :identity_providers

      def set_utc_offset
        current = TZInfo::Timezone.get(self.timezone).current_period
        self.utc_offset = current.utc_total_offset / 60
      end

      def self.linked_fields
        [:teachers, :sections, :students, :schedules]
      end

    end
  end
end
