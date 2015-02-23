require 'spec_helper'

describe Academical::Routes::Students do

  to_update = {"username" => "nidrog" }
  to_remove = ["email"]
  let(:resource_to_create) {
    s = create(:school)
    build(:student, school: s)
  }

  it_behaves_like Academical::Routes::ModelRoutes, to_update, to_remove,
    [:schedules], [:school, :registered_schedule]

  describe "get /students/:resource_id/schedules" do ||
    let(:student) { resource_to_create }
    before(:each) do
      schedules = create_list(
        :schedule,
        2,
        student: student,
        school: student.school
      )
      student.schedules = schedules
      student.save!
    end

    it "retreives student's schedules with embedded sections when requested" do
      get "/students/#{student.id}/schedules?include_sections"
      schedules = json_response
      schedules.each do |schedule|
        expect(schedule).to have_key("sections")
        expect(schedule["sections"].count).to eq(2)
      end
    end

    it "retreives student's schedules with expanded section events when requested" do
      get "/students/#{student.id}/schedules?include_sections&expand_section_events"
      schedules = json_response
      schedules.each do |schedule|
        expect(schedule).to have_key("sections")
        expect(schedule["sections"].count).to eq(2)
        schedule["sections"].each do |section|
          section["events"].each {|e| expect(e).to have_key("expanded")}
        end
      end
    end

  end
end

