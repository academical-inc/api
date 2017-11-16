module Academical
  module Helpers
    module AuthHelpers
      module_function

      # Return an instance of JWTUtils::TokenValidator.
      def token_validator
        @token_validator ||= JWTUtils::TokenValidator.new(
          settings.cache, logger
        )
      end

      # Fetch the authentication token from the HTTP header.
      #
      # Return the JWT from the HTTP_AUTHORIZATION header.
      def auth_header_token
        authorization = env['HTTP_AUTHORIZATION']
        raise InvalidTokenError if authorization.nil?
        authorization.split(' ').last
      end

      # Validates the current token and returns the corresponding handler.
      #
      # token - Decoded JWT.
      #
      # Return instance of a Token Handler.
      #
      # Raises InvalidTokenError if the token fails validation.
      def validate_token(token)
        validator = token_validator
        payload, = token_validator.decode_token(token)
        token_handler = Auth::TokenHandlerFactory.create_token_handler(payload)
        secret = token_handler.secret
        options = token_handler.verifications
        options[:jwks_uri] = token_handler.jwks_uri if secret.nil?
        validator.decode_and_validate_token(token, secret, options)
        token_handler
      rescue TokenValidationError => e
        logger.warn("Couldn't validate token: #{e.message}")
        raise InvalidTokenError
      end

      # Indicates if the current request has been authenticated.
      def logged_in?
        @token_handler ||= validate_token auth_header_token
        true
      end

      # Get the current student.
      #
      # Returns the current student if a valid authentication has happened.
      def current_student
        if is_admin?
          Student.find params[:student_id]
        elsif logged_in?
          @current_student ||= \
            Student.find_by auth0_user_id: @token_handler.current_user
        end
      end

      # Get the current school.
      def current_school
        if is_admin?
          School.find_by nickname: params[:school]
        else
          current_student.school
        end
      end

      # Returns the roles the authenticated user has.
      def roles
        roles = []
        roles = @token_handler.roles if logged_in?
        roles
      end

      # Indicates if the current user has an admin role.
      def is_admin?
        roles.include? 'admin'
      end

      # Indicates if the current user has a student role.
      def is_student?
        roles.include? 'student'
      end

      # Helper method to execute authorization blocks.
      def authorize!(code = 404, &block)
        raise NotAuthorizedError.new(code) unless block.call
      end
    end
  end
end
