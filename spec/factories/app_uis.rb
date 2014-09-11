FactoryGirl.define do

  factory :app_ui do
    search_filters { { "CBU" => "custom.cbu" } }
    summary_fields { { "CRN" => "section_id" } }
    search_result_fields { { "main" => "name" } }
    info_fields [ {"Profesores" => "teacher_names"} ]
  end

end
