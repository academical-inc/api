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

    begin
      School.remove_indexes
      Student.remove_indexes
      Section.remove_indexes
      Schedule.remove_indexes
      Teacher.remove_indexes
    rescue => ex
      puts "Indexes don't exist. Skipping index removal."
      puts ex
    ensure
      School.create_indexes
      Student.create_indexes
      Section.create_indexes
      Schedule.create_indexes
      Teacher.create_indexes
      puts "Successfully created indexes"
    end
  end

  task :clean, :environment do |t, args|
    unless args[:environment]
      puts "Must provide an environment"
      exit
    end

    unless ["production", "development", "test"].include? args[:environment]
      puts "Invalid environment"
      exit
    end

    Mongoid.load!('config/mongoid.yml', args[:environment].to_sym)

    School.delete_all
    Student.delete_all
    Section.delete_all
    Schedule.delete_all
    Teacher.delete_all
    puts "Successfully deleted all documents in database"
  end
end
