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
    # Factory for token handlers.
    #
    # The factory performs construction of token handlers for JWTs depending on
    # their contents. Two methods are provided, one for registering handlers
    # and the other one for creating a handler given a token's payload.
    class TokenHandlerFactory
      # Register a token handler for a given issuer.
      #
      # issuer - Hostname of the token issuer.
      # klass - Class definition of the token handler.
      def self.register_handler(issuer, klass)
        @handlers ||= {}
        @handlers[issuer] = klass
      end

      # Create a token handler for the given token.
      #
      # token_payload - Decoded token paylod.
      #
      # Returns an instance of a token handler class.
      #
      # Raises InvalidTokenError if the token doesn't provide an issuer.
      # Raises InvalidTokenIssuerError if the issuer doesn't have a handler.
      def self.create_token_handler(token_payload)
        raise InvalidTokenError unless token_payload['iss']
        issuer = URI.parse(token_payload['iss']).hostname
        raise InvalidTokenIssuerError, issuer unless @handlers[issuer]
        @handlers[issuer].new(token_payload)
      end
    end

    # Helper module to allow an easy way to register token handlers.
    #
    # When adding a token handler, extend the module and define for which issuer
    # the token handler should be used.
    module RegistrableHandler
      # Register the current class to handle tokens by issuer.
      #
      # issuer - Hostname of the issuer.
      def register_handler_for_issuer(issuer)
        @issuer = issuer
        TokenHandlerFactory.register_handler(issuer, self)
      end
    end
  end
end

handlers = Dir[File.expand_path('../handlers/**/*.rb', __FILE__)]
handlers.each do |handler|
  require handler
end
