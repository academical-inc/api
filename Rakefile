require File.expand_path '../api.rb', __FILE__

def validate_env(args)
  unless args[:environment]
    puts "Must provide an environment"
    exit
  end

  unless ["production", "development", "staging", "test"].include? args[:environment]
    puts "Invalid environment"
    exit
  end
end

def remove_indexes
  Section.remove_indexes
  Student.remove_indexes
  School.remove_indexes
  Teacher.remove_indexes
  Schedule.remove_indexes
  SectionDemand.remove_indexes
end

namespace :db do
task :remove_indexes, :environment do |t, args|
    validate_env args

    Mongoid.load!('config/mongoid.yml', args[:environment].to_sym)
    remove_indexes
    puts "Successfully removed all indexes"
  end
  task :create_indexes, :environment do |t, args|
    validate_env args

    Mongoid.load!('config/mongoid.yml', args[:environment].to_sym)

    begin
      remove_indexes
    rescue => ex
      puts "Indexes don't exist. Skipping index removal."
      puts ex
      puts ex.backtrace
    ensure
      School.create_indexes
      Student.create_indexes
      Section.create_indexes
      Schedule.create_indexes
      Teacher.create_indexes
      SectionDemand.create_indexes
      puts "Successfully created indexes"
    end
  end

  task :clean, :environment do |t, args|
    validate_env args

    Mongoid.load!('config/mongoid.yml', args[:environment].to_sym)

    School.delete_all
    Student.delete_all
    Section.delete_all
    Schedule.delete_all
    Teacher.delete_all
    puts "Successfully deleted all documents in database"
  end
end
