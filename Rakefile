require File.expand_path '../api.rb', __FILE__

namespace :db do
  task :create_indexes, :environment do |t, args|
    unless args[:environment]
      puts "Must provide an environment"
      exit
    end

    unless ["production", "development", "test"].include? args[:environment]
      puts "Invalid environment"
      exit
    end

    Mongoid.load!('config/mongoid.yml', args[:environment].to_sym)

    School.create_indexes
    Student.create_indexes
    Section.create_indexes
    Schedule.create_indexes

  end
end
