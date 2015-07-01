require 'spec_helper'

describe Academical::Routes::Students do

  to_update = {"email" => "nidrog@gmail.co" }
  to_remove = ["email"]
  before(:each) do
    make_admin true
  end
  let(:resource_to_create) {
    s = create(:school)
    build(:student, school: s)
  }

  it_behaves_like Academical::Routes::ModelRoutes, to_update, to_remove,
    [:schedules], [:registered_schedule]


  describe "get /students" do
    let!(:student) { create(:student) }

    it 'fails when not logged in' do
      make_logged_in false
      get "/students"
      expect_not_found_error
    end

    it 'fails if student' do
      make_student true, student
      get "/students"
      expect_not_found_error
    end

    it 'succeeds if admin' do
      get "/students"
      expect_correct_models [student.id]
    end

  end

  describe "get /students/:resource_id" do
    let!(:student) { create(:student) }
    let(:path) { "/students/#{student.id}" }

    it 'fails when not logged in' do
      make_logged_in false
      get path
      expect_not_found_error
    end

    it 'fails if current_student is not owner' do
      make_student true, create(:student)
      get path
      expect_not_found_error
    end

    it 'succeeds when current_student is owner' do
      make_student true, student
      get path
      expect_correct_model student.id
    end

    it 'succeeds when admin' do
      get path
      expect_correct_model student.id
    end

  end

  describe "get /students/:resource_id/schedules" do ||
    let!(:student) { create(:student) }
    let!(:schedules) {
      student.schedules = create_list(
        :schedule,
        2,
        student: student,
        school: student.school
      )
    }
    let(:ids) { schedules.collect { |s| s.id } }
    let(:path) { "/students/#{student.id}/schedules" }

    it 'fails when not logged in' do
      make_logged_in false
      get path
      expect_not_found_error
    end

    it 'fails when current_student is not owner' do
      make_student true, create(:student)
      get path
      expect_not_found_error
    end

    it 'succeeds when current_student is owner' do
      make_student true, student
      get path
      expect_correct_models ids
    end

    it 'succeeds when admin' do
      make_admin true
      get path
      expect_correct_models ids
    end

    it 'expands events when option provided' do
      get "#{path}?expand_events"
      res = expect_correct_models ids

      res.each do |sch|
        expect(sch["events"].count).to eq(2)
        sch["events"].each do |event|
          expect(event).to have_key("expanded")
        end
      end
    end

    it "includes sections when option provided" do
      get "#{path}?include_sections"
      res = expect_correct_models ids

      res.each do |sch|
        expect(sch["sections"].count).to eq(2)
      end
    end

    it "expands section events when both options provided" do
      get "#{path}?include_sections&expand_events"
      res = expect_correct_models ids
      res.each do |sch|
        expect(sch["sections"].count).to eq(2)
        sch["sections"].each do |section|
          section["events"].each {|e| expect(e).to have_key("expanded")}
        end
      end
    end
  end

  describe "post /students" do
    let(:path) { "/students" }

    describe "when new student" do
      let(:student) { build(:student, school: create(:school)) }
      let(:json) { student.as_json.except "id" }

      it 'fails if not logged in' do
        make_logged_in false
        post_json path, json
        expect_not_authorized_error
      end

      it 'creates student correctly when student' do
        make_student true
        expect_model_to_be_created Student do
          post_json path, json
        end
      end

      it 'creates student correctly when admin' do
        make_admin true
        expect_model_to_be_created Student do
          post_json path, json
        end
      end
    end

    describe "when existing student" do
      let(:student) { create(:student, school: create(:school)) }
      let(:json) {
        student.email = "new@mail.co"
        student.as_json }
      let(:no_id) { json.except "id" }

      it 'fails if not logged in' do
        make_logged_in false
        post_json path, json
        expect_not_authorized_error
      end

      it 'fails if current_student not owner and id provided' do
        make_student true, create(:student)
        post_json path, json
        expect_not_authorized_error
      end

      it 'fails if current_student not owner and auth0_id provided' do
        make_student true, create(:student)
        post_json path, no_id
        expect_not_authorized_error
      end

      describe "when admin" do
        it 'updates student when existing student id provided' do
          expect_model_to_be_updated Student, student.id, email: "new@mail.co" do
            post_json path, json
          end
        end

        it 'updates student when existing student auth0_id provided' do
          expect_model_to_be_updated Student, student.id, email: "new@mail.co" do
            post_json path, no_id
          end
        end
      end

      describe "when current_student is owner" do
        it 'updates student when existing student id provided' do
          make_student true, student
          expect_model_to_be_updated Student, student.id, email: "new@mail.co" do
            post_json path, json
          end
        end

        it 'updates student when existing student auth0_id provided' do
          make_student true, student
          expect_model_to_be_updated Student, student.id, email: "new@mail.co" do
            post_json path, no_id
          end
        end
      end
    end
  end

  describe "put /students/:resource_id" do
    let(:student) { create(:student) }
    let(:json) {
      student.name = "new"
      student.as_json.except "id"
    }
    let(:path) { "/students/#{student.id}" }

    it 'fails if not logged in' do
      make_logged_in false
      put_json path, json
      expect_not_found_error
    end

    it 'fails if student' do
      make_student true, student
      put_json path, json
      expect_not_found_error
    end

    it 'succeeds if admin' do
      expect_model_to_be_updated Student, student.id, name: "new" do
        put_json path, json
      end
    end
  end

  describe "delete /students/:resource_id" do
    let(:student) { create(:student) }
    let(:path) { "/students/#{student.id}" }

    it 'fails if not logged in' do
      make_logged_in false
      delete path
      expect_not_found_error
    end

    it 'fails if student' do
      make_student true, student
      delete path
      expect_not_found_error
    end

    it 'succeeds if admin' do
      expect_model_to_be_deleted Student, student.id do
        delete path
      end
    end
  end
end

