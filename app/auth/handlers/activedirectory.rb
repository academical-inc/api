#
# Copyright (C) 2012-2019 Academical Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

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
