module Academical
  module Models

    class School

      include Mongoid::Document
      include Mongoid::Timestamps

      field :name
      field :contact_info, type: Hash, default: {}
      field :active_modules, type: Array, default: []
      field :departments_list, type: Array, default: []
      field :urls, type: Hash, default: {}
      field :links, type: Hash, default: {}
      field :custom, type: Hash, default: {}

      before_create :update_links
      validates_presence_of :name


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
