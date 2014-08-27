module Academical
  module Models

    class School

      include Mongoid::Document
      include Mongoid::Timestamps

      field :name
      field :locale
      field :active_modules, type: Array, default: []
      field :urls, type: Hash, default: {}
      field :custom, type: Hash, default: {}
      field :links, type: Hash, default: {}
      embeds_one :contact_info
      embeds_one :location
      embeds_many :departments
      embeds_many :app_uis
      embeds_many :assets, class_name: "SchoolAssets"
      embeds_many :terms, class_name: "SchoolTerm" do
        def latest_term
          max(:start_date)
        end
      end

      before_create :update_links
      validates_presence_of :name, :locale, :departments, :terms


      def update_links
        base_url = "/schools/#{self._id}"
        self.links[:self] = base_url
        self.links[:teachers] = "#{base_url}/teachers"
        self.links[:sections] = "#{base_url}/sections"
        self.links[:students] = "#{base_url}/students"
        self.links[:schedules] = "#{base_url}/schedules"
      end

    end

  end
end
