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

describe AuthHelpers do
  let(:client_id) { 'my-client-id, so secret, so great' }

  it 'should be unauthorized without authentication header' do
    get '/'
    expect(last_response.status).to eq(401)
  end

  it 'should be unathorized with a random authentication header' do
    get '/', {}, authorization_header(SecureRandom.base64(50))
    expect(last_response.status).to eq(401)
  end

  context 'with an Auth0 JWT' do
    let(:client_secret) { '$o$ecret$o$afe' }
    let(:token_payload) do
      {
        aud: client_id,
        app_metadata: { roles: [:admin] },
        iss: 'https://academical.auth0.com/',
        sub: 'facebook|91919191'
      }
    end
    let(:env) do
      {
        'AUTH0_CLIENT_ID' => client_id,
        'AUTH0_CLIENT_SECRET' => JWT::Encode.base64url_encode(client_secret)
      }
    end
    let(:token) { JWT.encode token_payload, client_secret, 'HS256' }

    before(:each) do
      stub_const('ENV', ENV.to_hash.merge(env))
    end

    it 'should fail if the token has the wrong audience' do
      token_payload[:aud] = 'something totally unexpected'
      get '/', {}, authorization_header(token)
      expect(last_response.status).to eq(401)
    end

    it 'should fail if the token has no app_metadata' do
      token_payload.delete(:app_metadata)
      get '/', {}, authorization_header(token)
      expect(last_response.status).to eq(401)
    end

    it 'should authenticate with a valid admin token' do
      get '/', {}, authorization_header(token)
      expect(last_response).to be_ok
    end

    it 'should authenticate with a valid student token' do
      token_payload[:app_metadata][:roles] = [:student]
      allow_any_instance_of(Academical::Routes::Sections).to receive(:search) do
        { data: [] }
      end

      get '/sections/search', { q: 'test' }, authorization_header(token)

      expect(last_response).to be_ok
    end
  end

  context 'with a AD JWT' do
    let(:key) { OpenSSL::PKey::RSA.generate 2048 }
    let(:token_payload) do
      {
        aud: client_id,
        iss: 'https://sts.windows.net/b9411234-09af-49c2-b0c3-653adc1f376e',
        upn: 'someone@uniandes.edu.co'
      }
    end
    let(:token) do
      JWT.encode token_payload, key, 'RS256', 'kid' => key.to_jwk['kid']
    end
    let(:env) { { 'AD_CLIENT_ID' => client_id } }
    let(:provider_response) { { 'keys' => [key.public_key.to_jwk] } }

    before(:each) do
      allow_any_instance_of(JWTUtils::TokenValidator)
        .to receive('request_jwks') { provider_response }
      allow_any_instance_of(Academical::Routes::Sections)
        .to receive(:search) { { data: [] } }
      stub_const('ENV', ENV.to_hash.merge(env))
    end

    it 'should fail if the key is not valid per provider' do
      provider_response['keys'] = [OpenSSL::PKey::RSA.generate(2048).to_jwk]
      get '/sections/search', { q: 'test' }, authorization_header(token)
      expect(last_response.status).to eq(401)
    end

    it 'should fail if the token has the wrong audience' do
      token_payload[:aud] = 'something totally unexpected'
      get '/', {}, authorization_header(token)
      expect(last_response.status).to eq(401)
    end

    it 'should not be unauthorized to do admin requests' do
      get '/', {}, authorization_header(token)
      expect(last_response.status).to eq(403)
    end

    it 'should authenticate with a valid student token' do
      get '/sections/search', { q: 'test' }, authorization_header(token)
      expect(last_response).to be_ok
    end
  end
end
