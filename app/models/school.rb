module Academical
  module Models
    class School

      include Mongoid::Document
      include Mongoid::Timestamps
      include Linkable

      field :name, type: String
      field :locale, type: String
      field :custom, type: Hash
      field :active_modules, type: Array
      field :urls, type: Hash
      embeds_one :contact_info
      embeds_one :location
      embeds_one :assets, class_name: "SchoolAssets"
      embeds_many :app_uis
      embeds_many :departments
      embeds_many :terms, class_name: "SchoolTerm" do
        def latest_term
          desc(:start_date).limit(1).first
        end
      end
      has_many :teachers
      has_many :students

      index({name: 1}, {name: "name_index"})
      index({"terms.start_date"=> 1}, {name: "terms_index"})

      validates_presence_of :name, :locale, :departments, :terms, :assets

      def linked_fields
        [:teachers, :sections, :students, :schedules]
      end

    end
  end
end
