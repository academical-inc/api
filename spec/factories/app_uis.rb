FactoryGirl.define do

  factory :app_ui do
    search_filters [ {"name"=>"Tipo", "values"=>["A", "B", "E"], "field"=>"custom.cbu"} ]
    summary_fields [ {"name" => "CRN", "field"=>"section_id"} ]
    search_result_fields { { "main" => "name" } }
    info_fields [ {"Profesores" => "teacher_names"} ]
  end

end
