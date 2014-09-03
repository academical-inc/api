FactoryGirl.define do

  factory :school do

    name "Universidad de los Andes"
    locale "es"

    departments { build_list(:department, 5) }
    terms { [build(:school_term), build(:school_term, year: 2014, month: 8), \
             build(:school_term, year: 2014)] }
    assets { build(:school_assets) }
  end

end
