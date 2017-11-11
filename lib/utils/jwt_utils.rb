module Academical
  module Helpers
    module JWTUtils
      # The token validator provides methods to decode and validate JWT tokens.
      # It will perform the necessary queries to retrieve JWK keys from the
      # providers if necessary. A cache store must be given to store the
      # JWK keys after retrieval.
      class TokenValidator
        # Initialize a token validator.
        #
        # cache - ActiveSupport cache store instance.
        # logger - logger for logging errors during validation.
        def initialize(cache, logger)
          @cache = cache
          @logger = logger
        end

        # Decodes and validates a JWT.
        #
        # The function validates a JWT token regardless of the algorithm needed
        # for it's verification. If the secret is nil, an option with the name
        # jwks_uri must be provided. This URL will be requested for the keys.
        #
        # token - The JWT token to be decoded and validated.
        # secret - Secret to be used on validation, if any.
        # options - Hash with options indicating which verifications to be done.
        #           See ruby-jwt:lib/jwt/default_options.rb
        #
        # Returns the payload of the decoded/verified token.
        #
        # Raises a TokenValidationError if the token is found to be invalid.
        def decode_and_validate_token(token, secret, options = {})
          options.merge!(identify_signature_algorithm(token))
          if secret.nil?
            raise ArgumentError, 'Missing secret or jwks_uri in options hash' \
              unless options[:jwks_uri]
            JWT.decode(token, secret, true, options) do |header|
              fetch_key header, options[:jwks_uri]
            end[0]
          else
            JWT.decode(token, secret, true, options)[0]
          end
        rescue JWT::DecodeError => e
          @logger.warn('Unable to validate token : ' + e.message)
          raise TokenValidationError, e.message
        end

        # Decodes the JWT token without validation.
        #
        # WARNING: Although this function returns the header and payload of the
        # token, their contents shouldn't be relied upon until the signature
        # has been verified.
        #
        # token - The JWT token to be decoded.
        #
        # Returns payload, header of the decoded token.
        #
        # Raises an TokenValidationError if the token is invalid.
        def decode_token(token)
          JWT.decode token, nil, false
        rescue JWT::DecodeError => e
          @logger.warn('Unable to decode token : ' + e.message)
          raise TokenValidationError, e.message
        end

        private

        # Fetches the necessary keys to perform a RSA signature validation.
        #
        # The method relies on the cache provided on initialization for storing
        # the keys retrieved.
        #
        # headers - The JWT headers. Used to retrieve the key kid.
        # jwks_uri - The URL to use to retrieve the keys.
        #
        # Returns the JWK keys.
        #
        # Raises a TokenValidationError if we're unable to fetch a valid key.
        def fetch_key(headers, jwks_uri)
          raise TokenValidationError, 'Missing kid identifier' \
            unless headers['kid']

          kid = headers['kid']
          keys = @cache.fetch(jwks_uri, expires_in: 1.day) do
            contents = request_jwks jwks_uri
            keys = contents['keys']
            keys.each_with_object({}) { |e, hash| hash[e['kid']] = e }
          end

          raise TokenValidationError, 'No key matching kid found' \
            unless keys[kid]
          JSON::JWK.new(keys[kid]).to_key
        end

        def request_jwks(jwks_uri)
          JSON.parse(open(jwks_uri).read)
        end

        def identify_signature_algorithm(token)
          _, header = decode_token(token)
          { algorithm: header['alg'] }
        end
      end
    end
  end
end
