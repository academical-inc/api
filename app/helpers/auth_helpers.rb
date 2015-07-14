module Academical
  module Helpers
    module AuthHelpers

      AUTH0_CLIENT_ID = ENV['AUTH0_CLIENT_ID']
      AUTH0_CLIENT_SECRET = ENV['AUTH0_CLIENT_SECRET']

      module_function

      def validate_token
        begin
          authorization = env['HTTP_AUTHORIZATION']
          raise InvalidTokenError if authorization.nil?

          token = authorization.split(' ').last
          decoded = JWT.decode(token,
            JWT.base64url_decode(AUTH0_CLIENT_SECRET))[0]

          raise InvalidTokenError if AUTH0_CLIENT_ID != decoded["aud"]
          decoded
        rescue JWT::DecodeError
          raise InvalidTokenError
        end
      end

      def logged_in?
        @decoded_token ||= validate_token
        true
      end

      def current_student
        if is_admin?
          {user: "admin"}
        else
          @current_student ||= Student.find_by auth0_user_id: @decoded_token["sub"] if logged_in?
        end
      end

      def current_school
        if is_admin?
          params[:school]
        else
          current_student.school
        end
      end

      def roles
        return @decoded_token["app_metadata"]["roles"] if logged_in?
        []
      end

      def is_admin?
        roles.include? "admin"
      end

      def is_student?
        roles.include? "student"
      end

      def authorize!(code=404, &block)
        raise NotAuthorizedError.new(code) if not block.call
      end

    end
  end
end
