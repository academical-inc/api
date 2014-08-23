module Academical
  module Models

    class School

      include Mongoid::Document
      include Mongoid::Timestamps

      field :phone
      field :custom, type: Hash
      field :departments_list, type: Array
      field :active_modules, type: Array
      field :urls, type: Hash
      field :links, type: Hash

      after_create :update_links

      def update_links
        base_url = "/schools/#{self._id}"
        self.links[:self] = base_url
        self.links[:teachers] = "#{base_url}/teachers"
        self.links[:sections] = "#{base_url}/sections"
        self.links[:students] = "#{base_url}/students"
        self.links[:schedules] = "#{base_url}/schedules"
        save!
      end

    end

  end
end
