module Academical
  module Auth
    # ActiveDirectory JWT Handler.
    #
    # Provides methods to manage a JWT issued by Active Directory.
    #
    # TODO - Reaching directly into ENV is less than ideal. If we need to
    # further extend the functionality we should consider using a secret
    # management service.
    #
    class ActiveDirectoryHandler
      extend RegistrableHandler

      # Issuer for which this token handler is valid.
      register_handler_for_issuer 'sts.windows.net'

      # Create a token handler for the token with the given payload.
      #
      # payload - Decoded JWT.
      def initialize(payload)
        validate_payload(payload)
        @payload = payload
      end

      # Return the user ID of the current user.
      #
      # TODO - HAX - Once the current term ends 2017-2 we should remove the
      # dependency on the Auth0 field and format.
      def current_user
        "waad|#{@payload['upn']}"
      end

      # Return the roles of the current user.
      #
      # This is less than ideal as the current token doesn't have any metadata.
      def roles
        ['student']
      end

      # Provides the verifications needed for the token.
      #
      # See ruby-jwt:lib/jwt/default_options.rb for all possible verifications.
      def verifications
        { verify_aud: true, aud: ENV['AD_CLIENT_ID'] }
      end

      # The secret needed to decode the token.
      def secret
        nil
      end

      # JWKs URL used to retrieve the secret if needed.
      def jwks_uri
        'https://login.microsoftonline.com/common/discovery/v2.0/keys'
      end

      private

      def validate_payload(payload)
        raise IncompleteTokenPayload, 'upn' unless payload['upn']
      end
    end
  end
end
