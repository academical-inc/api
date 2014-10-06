FactoryGirl.define do

  sequence(:school_name) { |n| "University #{n}" }

  factory :school do

    name { generate :school_name }
    nickname { name.underscore.gsub(" ", "_") }
    locale "es"

    departments { build_list(:department, 5) }
    terms { [build(:school_term), build(:school_term, year: 2014, month: 8), \
             build(:school_term, year: 2014)] }
    assets { build(:school_assets) }
    app_ui { build(:app_ui) }

    initialize_with { School.find_or_create_by(name: name) }
  end

end
