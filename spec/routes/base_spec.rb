require 'spec_helper'

# Tests general api behavior
describe Academical::Routes::Base do

  describe 'before filters' do
    let(:payload) { {any: "data"}.to_json }

    it 'should not return error if content-type missing on GET' do
      make_admin true
      get '/'
      expect(last_response).to be_ok
    end

    it 'should return error if content-type missing on POST' do
      post '/', payload
      expect_content_type_error
    end

    it 'should return error if content-type missing on PUT' do
      put '/', payload
      expect_content_type_error
    end
  end

  describe 'auth' do
    def app
      Class.new Academical::Routes::Base do
        set :environment, :production
        get '/' do
          authorize! { logged_in? }
          json_response "data"
        end

        get '/admin' do
          authorize!(403) { is_admin? }
          json_response "data"
        end

        get '/student' do
          authorize!(403) { is_student? }
          json_response "data"
        end
      end
    end

    it 'should return 401 error when token not provided' do
      get "/"
      expect_invalid_auth_error
    end

    it 'should return 401 error when invalid auth token provided' do
      get "/", {}, {"HTTP_AUTHORIZATION" => "12345"}
      expect_invalid_auth_error
    end

    it 'should return 401 error when request from invalid client' do
      allow(JWT).to receive(:decode) { [{"aud"=>"12345"}] }
      get "/", {}, {"HTTP_AUTHORIZATION" => "12345"}
      expect_invalid_auth_error
    end

    it 'should return 403 error when not authorized to access' do
      allow_any_instance_of(Academical::Routes::Base).to receive(:validate_token) {
        {"app_metadata" => {"roles" => []}}
      }
      get "/admin"
      expect_not_authorized_error
      get "/student"
      expect_not_authorized_error
    end

    it 'should return 403 error when student and not authorized to access' do
      allow_any_instance_of(Academical::Routes::Base).to receive(:validate_token) {
        {"app_metadata" => {"roles" => ["student"]}}
      }
      get "/admin"
      expect_not_authorized_error
      get "/student"
      json_response
    end

    it 'should return 403 error when admin and not authorized to access' do
      allow_any_instance_of(Academical::Routes::Base).to receive(:validate_token) {
        {"app_metadata" => {"roles" => ["admin"]}}
      }
      get "/admin"
      json_response
      get "/student"
      expect_not_authorized_error
    end

    it 'should succeed when appropriate roles granted' do
      allow_any_instance_of(Academical::Routes::Base).to receive(:validate_token) {
        {"app_metadata" => {"roles" => ["admin", "student"]}}
      }
      get "/"
      json_response
      get "/admin"
      json_response
      get "/student"
      json_response
    end
  end

  describe 'error handlers' do
    def error_app(error = StandardError)
      Class.new Academical::Routes::Base do
        set :environment, :production
        get '/' do
          raise error
        end
      end
    end

    it 'should return 500 error when an unexpected error is raised' do
      def app; error_app; end
      get '/'
      json_error 500
    end

    it 'should return 404 error when an unknown path is requested' do
      def app; error_app; end
      get '/unknown'
      expect_invalid_path_error
    end

    it 'should return 400 error when a parameter missing error is raised' do
      def app; error_app(ParameterMissingError.new(:field)); end
      get '/'
      expect_missing_parameter_error :field
    end
  end

  describe 'cross origin' do

    it 'should return the correct CORS header' do
      origin = 'http://app.uniandes.academical.co'
      header 'Origin', origin
      get '/'
      expect(last_response.headers["Access-Control-Allow-Origin"]).to eq(origin)
    end
  end

end

