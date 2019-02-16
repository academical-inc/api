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

require 'spec_helper'

describe JWTUtils::TokenValidator do
  let(:test_cache) { ActiveSupport::Cache::MemoryStore.new }
  let(:validator) do
    JWTUtils::TokenValidator.new(test_cache, Logger.new(nil))
  end

  context 'when alg is MAC based' do
    let(:token_payload) { { 'testing' => 'yes', 'auth' => true } }
    let(:secret) { 'SO$ECRETSO$AFE' }
    let(:token) { JWT.encode token_payload, secret, 'HS256' }

    it "retrieves token's contents" do
      expect(validator.decode_and_validate_token(token, secret))
        .to eq(token_payload)
    end

    it 'fails if no secret or jwks_uri is provided' do
      expect { validator.decode_and_validate_token(token, nil) }
        .to raise_error(ArgumentError)
    end

    it 'fails on a expired token' do
      token_payload[:exp] = Time.now.to_i
      token = JWT.encode token_payload, secret, 'HS256'

      expect { validator.decode_and_validate_token(token, secret) }
        .to raise_error(TokenValidationError)
    end

    it 'fails if the aud provided is invalid and validation is requested' do
      token_payload[:aud] = 'MY_AWESOME-AUD'
      expect do
        validator.decode_and_validate_token(
          token, secret, verify_aud: true, aud: 'WRONG-AUD'
        )
      end.to raise_error(TokenValidationError)
    end

    it 'fails on invalid secrets' do
      expect { validator.decode_and_validate_token(token, 'OHUHNOT$O$SAFE') }
        .to raise_error(TokenValidationError)
    end
  end

  context 'when alg is RSA based' do
    let(:key) { OpenSSL::PKey::RSA.generate 2048 }
    let(:second_key) { OpenSSL::PKey::RSA.generate 2048 }
    let(:token_payload) do
      {
        'testing' => 'yes',
        'auth' => true,
        'iss' => 'https://sts.windows.net/b9411234-09af-49c2-b0c3-653adc1f376e',
        'aud' => 'DEFAULT_VALUE'
      }
    end
    let(:token) do
      JWT.encode token_payload, key, 'RS256', 'kid' => key.to_jwk['kid']
    end
    let(:provider_response) do
      { 'keys' => [key.public_key.to_jwk, second_key.public_key.to_jwk] }
    end

    it "retrieves token's contents" do
      expect(validator.decode_and_validate_token(token, key.public_key))
        .to eq(token_payload)
    end

    it 'fails on a mistmatched key' do
      temporary_key = OpenSSL::PKey::RSA.generate 2048
      expect do
        validator.decode_and_validate_token(token, temporary_key.public_key)
      end.to raise_error(TokenValidationError)
    end

    it 'fails on a expired token' do
      token_payload[:exp] = Time.now.to_i
      token = JWT.encode token_payload, key, 'RS256'

      expect { validator.decode_and_validate_token(token, key.public_key) }
        .to raise_error(TokenValidationError)
    end

    it 'fails if the aud provided is invalid and validation is requested' do
      token_payload[:aud] = 'MY_AWESOME-AUD'
      expect do
        validator.decode_and_validate_token(
          token, key.public_key, verify_aud: true, aud: 'WRONG-AUD'
        )
      end.to raise_error(TokenValidationError)
    end

    it 'retrieves key if not provided' do
      allow(validator).to receive('request_jwks') { provider_response }

      expect(validator.decode_and_validate_token(token, nil, jwks_uri: 'url'))
        .to eq(token_payload)
    end

    it 'properly caches key response when fetching keys' do
      second_token = JWT.encode token_payload, second_key, 'RS256',
                                'kid' => second_key.to_jwk['kid']
      allow(validator).to receive('request_jwks') { provider_response }

      validator.decode_and_validate_token(token, nil, jwks_uri: 'url')
      validator.decode_and_validate_token(second_token, nil, jwks_uri: 'url')

      expect(validator).to have_received('request_jwks').once
    end
  end
end
