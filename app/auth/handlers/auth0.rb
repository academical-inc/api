module Academical
  module Auth
    # Auth0 JWT Handler.
    #
    # Provides methods to manage an Auth0 token payload.
    #
    # TODO - Reaching directly into ENV is less than ideal. If we need to
    # further extend the functionality we should consider using a secret
    # management service.
    #
    class Auth0Handler
      extend RegistrableHandler

      # Issuer for which this token handler is valid.
      register_handler_for_issuer 'academical.auth0.com'

      # Creates a token handler for the token with the given payload.
      #
      # payload - Decoded JWT payload.
      def initialize(payload)
        validate_payload(payload)
        @payload = payload
      end

      # Return the user ID of the current user.
      def current_user
        @payload['sub']
      end

      # Return the roles of the current user.
      def roles
        @payload['app_metadata']['roles']
      end

      # Provides the verifications needed for the token.
      #
      # See ruby-jwt:lib/jwt/default_options.rb for all possible verifications.
      def verifications
        { verify_aud: true, aud: ENV['AUTH0_CLIENT_ID'] }
      end

      # The secret needed to decode the token.
      def secret
        JWT::Decode.base64url_decode(ENV['AUTH0_CLIENT_SECRET'])
      end

      # JWKs URL used to retrieve the secret if needed.
      def jwks_uri
        nil
      end

      private

      def validate_payload(payload)
        raise IncompleteTokenPayload, 'app_metadata' \
          unless payload['app_metadata']
        raise IncompleteTokenPayload, 'sub' \
          unless payload['sub']
      end
    end
  end
end
