require 'spec_helper'

describe Academical::Routes::Schedules do

  describe "get /schedules" do
    let!(:schedules) { create_list(:schedule, 3) }

    describe "when admin" do
      before(:each) do
        make_admin true
      end

      it 'retrieves schedules correctly' do
        get "/schedules"
        expect_correct_models(schedules.collect { |s| s.id })
      end

      it 'should return the number of resources when count requested' do
        get "/schedules?count"
        expect(json_response).to eq(3)
      end

      it 'should return a camelized object when option provided' do
        get "/schedules?camelize"
        expect_camelized_response
      end
    end

    it 'denies access when not admin' do
      make_admin false
      get "/schedules"
      expect_not_found_error
    end
  end

  describe "get /schedules/:resource_id" do

    describe "general" do
      before(:each) do
        make_admin true
      end
      let(:schedule) { create(:schedule) }

      it 'fails when schedule does not exist' do
        get "/schedules/123?include_sections"
        expect_not_found_error
      end

      it 'includes sections when option provided' do
        get "/schedules/#{schedule.id}?include_sections"
        res = expect_correct_model schedule.id
        expect(res["sections"].count).to eq(2)
      end

      it 'expands events when option provided' do
        get "/schedules/#{schedule.id}?expand_events"
        res = expect_correct_model schedule.id

        expect(res["events"].count).to eq(2)
        res["events"].each do |event|
          expect(event).to have_key("expanded")
        end
      end

      it 'expands section events when both options provided' do
        get "/schedules/#{schedule.id}?expand_events&include_sections"
        res = expect_correct_model schedule.id

        expect(res["events"].count).to eq(2)
        expect(res["sections"].count).to eq(2)
        res["events"].each do |event|
          expect(event).to have_key("expanded")
        end
        res["sections"].each do |sec|
          sec["events"].each do |event|
            expect(event).to have_key("expanded")
          end
        end
      end
    end

    describe "when schedule is public" do
      let(:schedule) { create(:schedule, public: true) }

      it 'returns schedule when admin' do
        make_admin true
        get "/schedules/#{schedule.id}"
        expect_correct_model schedule.id
      end

      it 'returns schedule when student' do
        make_student true
        get "/schedules/#{schedule.id}"
        expect_correct_model schedule.id
      end

      it 'returns schedule when neither' do
        make_logged_in false
        get "/schedules/#{schedule.id}"
        expect_correct_model schedule.id
      end
    end

    describe "when schedule is private" do
      let(:student) { create(:student) }
      let!(:schedule) { create(:schedule, student: student, school: student.school) }

      it 'returns schedule when admin' do
        make_admin true
        get "/schedules/#{schedule.id}"
        expect_correct_model schedule.id
      end

      it 'returns schedule when student owns schedule' do
        make_student true, student
        get "/schedules/#{schedule.id}"
        expect_correct_model schedule.id
      end

      it 'denies access when current_student is not owner' do
        make_student true, create(:student)
        get "/schedules/#{schedule.id}"
        expect_not_found_error
      end

      it 'denies access when neither' do
        make_logged_in true
        roles []
        get "/schedules/#{schedule.id}"
        expect_not_found_error
      end

      it 'denies access when logged out' do
        make_logged_in false
        get "/schedules/#{schedule.id}"
        expect_not_found_error
      end
    end
  end

  describe 'post /schedules' do
    let(:student) { create(:student, schedules: []) }
    let!(:schedule) {
      sch = build(:schedule, student: student, school: student.school)
      sch.sections.each { |s| s.save! }
      sch
    }
    let!(:json) { schedule.as_json.except "id" }
    let(:base_path) { "/schedules" }

    it 'fails when not logged in' do
      make_logged_in false
      post_json base_path, json
      expect_not_authorized_error
    end

    it 'fails when student not provided and is admin' do
      make_admin true
      post_json base_path, json.except("student_id")
      expect_validation_error
    end

    it 'fails when student not provided and is student' do
      make_student true, student
      post_json base_path, json.except("student_id")
      expect_not_authorized_error
    end

    it 'fails when current_student is not owner' do
      make_student true, create(:student)
      post_json base_path, json
      expect_not_authorized_error
    end

    it 'should fail when payload does not have correct data key' do
      post_json base_path, json, root: false
      expect_missing_parameter_error
    end

    it 'should fail when resource data is invalid' do
      make_student true, student
      json["name"] = nil
      post_json base_path, json
      expect_validation_error
    end

    it 'should fail when required resource data is incomplete' do
      make_student true, student
      post_json base_path, json.except("name")
      expect_validation_error
    end

    it 'should fail when data is unknown' do
      make_student true, student
      json["some"] = "thing"
      post_json base_path, json
      expect_unknown_field_error "some"
    end

    it 'creates schedule when student is owner' do
      make_student true, student
      expect_model_to_be_created Schedule do
        post_json base_path, json
      end
    end

    it 'creates schedule when admin' do
      make_admin true
      expect_model_to_be_created Schedule do
        post_json base_path, json
      end
    end

    it 'includes sections when option provided' do
      make_student true, student
      res = expect_model_to_be_created Schedule do
        post_json base_path, {data: json, include_sections: true}, root: false
      end
      expect(res["sections"].count).to eq(2)
    end

    it 'expands events when option provided' do
      make_student true, student
      res = expect_model_to_be_created Schedule do
        post_json base_path, {data: json, expand_events: true}, root: false
      end

      expect(res["events"].count).to eq(2)
      res["events"].each do |event|
        expect(event).to have_key("expanded")
      end
    end

    it 'expands section events when both options provided' do
      make_student true, student
      res = expect_model_to_be_created Schedule do
        post_json base_path, {data: json, expand_events: true, include_sections: true}, root: false
      end

      expect(res["events"].count).to eq(2)
      expect(res["sections"].count).to eq(2)
      res["events"].each do |event|
        expect(event).to have_key("expanded")
      end
      res["sections"].each do |sec|
        sec["events"].each do |event|
          expect(event).to have_key("expanded")
        end
      end
    end
  end

  describe "put /schedules/:resource_id" do
    let(:student) { create(:student, schedules: []) }
    let!(:schedule) { create(:schedule, student: student, school: student.school) }
    let!(:json) {
      js = schedule.as_json.except "id"
      js["name"] = "New Name"
      js
    }
    let(:base_path) { "/schedules/#{schedule.id}" }

    it 'fails when not logged in' do
      make_logged_in false
      put_json base_path, json
      expect_not_found_error
    end

    it 'fails when current student is not owner' do
      make_student true, create(:student)
      put_json base_path, json
      expect_not_found_error
    end

    it 'should fail when payload does not have correct data key' do
      make_student true, student
      put_json base_path, json, root: false
      expect_missing_parameter_error
    end

    it 'should fail when resource data is invalid' do
      make_student true, student
      json["name"] = nil
      put_json base_path, json
      expect_validation_error
    end

    it 'should fail when data is unknown' do
      make_student true, student
      json["some"] = "thing"
      put_json base_path, json
      expect_unknown_field_error "some"
    end

    it 'should fail if id not provided in url'do
      make_student true, student
      put_json "/schedules", json
      expect_invalid_path_error
    end

    it 'should fail if resource does not exist' do
      make_student true, student
      put_json "/schedules/123", json
      expect_not_found_error
    end

    it 'updates schedule when admin' do
      make_admin true
      expect_model_to_be_updated Schedule, schedule.id, {name: "New Name"} do
        put_json base_path, json
      end
    end

    it 'updates schedule when student is owner' do
      make_student true, student
      expect_model_to_be_updated Schedule, schedule.id, {name: "New Name"} do
        put_json base_path, json
      end
    end

  end

  describe "delete /schedule/:resource_id" do
    let(:student) { create(:student, schedules: []) }
    let!(:schedule) { create(:schedule, student: student, school: student.school) }
    let(:base_path) { "/schedules/#{schedule.id}" }

    it 'fails when not logged in' do
      make_logged_in false
      delete base_path
      expect_not_found_error
    end

    it 'fails when current student is not owner' do
      make_student true, create(:student)
      delete base_path
      expect_not_found_error
    end

    it 'should fail if id not provided in url'do
      make_student true, student
      delete "/schedules"
      expect_invalid_path_error
    end

    it 'should fail if resource does not exist' do
      make_student true, student
      delete "/schedules/123"
      expect_not_found_error
    end

    it 'deletes schedule when admin' do
      make_admin true
      expect_model_to_be_deleted Schedule, schedule.id do
        delete base_path
      end
    end

    it 'deletes schedule when student is owner' do
      make_student true, student
      expect_model_to_be_deleted Schedule, schedule.id do
        delete base_path
      end
    end

  end

end
