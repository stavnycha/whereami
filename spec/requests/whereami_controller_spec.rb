require 'rails_helper'

describe 'WhereamiController', type: :request do
  describe "GET /whereami" do
    let(:ip) { '11.111.111.1' }
    let(:country_name) { 'Country name' }
    let(:location_response) { {ip: ip, country: country_name} }
    let(:accepted_language) { 'en-AU,en-US;q=0.7,en;q=0.3' }

    it 'should return "ip", "country" and "language" fields' do
      stub_request(:get, "http://ipinfo.io/#{ip}").
        to_return(status: 200, body: location_response.to_json)

      get '/whereami', env: {REMOTE_ADDR: ip}
      json_response = JSON.parse(response.body)
      expect(json_response.keys).to match_array(%w(ip country language))
    end

    context 'when remote IP is passed in the request' do
      before do
        stub_request(:get, "http://ipinfo.io/#{ip}").
          to_return(status: 200, body: location_response.to_json)
      end

      it 'returns this IP in response' do
        get '/whereami', env: {REMOTE_ADDR: ip}

        expect(response.status).to eq 200

        expect(JSON.parse(response.body)['ip']).to eq(ip)
      end
    end

    context 'when country is found by IP' do
      before do
        stub_request(:get, "http://ipinfo.io/#{ip}").
          to_return(status: 200, body: location_response.to_json)
      end

      it 'returns correspondent country in response' do
        get '/whereami', env: {REMOTE_ADDR: ip}

        expect(response.status).to eq 200
        expect(JSON.parse(response.body)['country']).to eq(country_name)
      end
    end

    context 'when remote IP is not passed in the request' do
      let(:ip) { nil }

      before do
        stub_request(:get, "http://ipinfo.io/").to_return(status: 200)
      end

      it 'returns "nil" for "ip" and "country" fields in response' do
        get '/whereami', env: {REMOTE_ADDR: nil}

        expect(response.status).to eq 200
        expect(JSON.parse(response.body)['ip']).to eq(nil)
        expect(JSON.parse(response.body)['country']).to eq(nil)
      end
    end

    context 'when country is not found by IP (404 response)' do
      before do
        stub_request(:get, "http://ipinfo.io/#{ip}").to_return(status: 404)
      end

      it 'returns "nil" for country field' do
        get '/whereami', env: {REMOTE_ADDR: ip}

        expect(response.status).to eq 200
        expect(JSON.parse(response.body)['country']).to be_nil
      end
    end

    context "when ACCEPT_LANGUAGE header is sent from client" do
      before do
        stub_request(:get, "http://ipinfo.io/#{ip}").
          to_return(status: 200, body: location_response.to_json)
      end

      it 'should return the most often used locale in response' do
        get '/whereami', env: {REMOTE_ADDR: ip}, headers: {HTTP_ACCEPT_LANGUAGE: accepted_language}
        expect(response.status).to eq 200
        expect(JSON.parse(response.body)['language']).to eq('en-AU')
      end
    end

    context "when ACCEPT_LANGUAGE header is not sent from client" do
      let(:accepted_language) { nil }

      before do
        stub_request(:get, "http://ipinfo.io/#{ip}").
          to_return(status: 200, body: location_response.to_json)
      end

      it 'should return nil for "language" field' do
        get '/whereami', env: {REMOTE_ADDR: ip}, headers: {HTTP_ACCEPT_LANGUAGE: accepted_language}
        expect(response.status).to eq 200
        expect(JSON.parse(response.body)['language']).to be_nil
      end
    end
  end
end