require 'spec_helper'

describe OverlayPublisher::App do

  def app
    @app ||= OverlayPublisher::App
  end

  describe "POST '/publish'" do
    it "should be successful" do
      redis = OverlayPublisher::Redis.instance
      allow(redis).to receive(:publish_hook).and_return(true)
      post '/publish', {'repository' => { 'name' => 'test', 'organization' => 'test_org'}}.to_json
      last_response.should be_ok
    end

    it 'should publish to redis' do
      payload = {'repository' => { 'name' => 'test', 'organization' => 'test_org'}}.to_json
      redis = OverlayPublisher::Redis.instance
      allow(redis).to receive(:publish_hook).and_return(true)
      expect(redis).to receive(:publish_hook).with(payload).exactly(1).times
      post '/publish', payload
      last_response.should be_ok
    end
  end

  describe "POST /register" do
    let(:payload) do
      payload = {
                  'organization' => 'test_org',
                  'repo' => 'test_repo',
                  'auth' => 'user:pass',
                  'endpoint' => 'http://api.github.com',
                  'site' => 'http://github.com'
                }
      payload.to_json
    end

    let(:bad_payload) do
      payload = {
                  'organization' => 'test_org',
                  'auth' => 'user:pass',
                  'endpoint' => 'http://api.github.com',
                  'site' => 'http://github.com'
                }
      payload.to_json
    end

    it "should be successfull on valid call" do
      allow(OverlayPublisher::Github).to receive(:register_webhooks).and_return(true)
      post '/register', payload
      last_response.should be_ok
    end

    it 'should throw error on invalid call' do
      expect{post '/register', bad_payload}.to raise_error
    end

    it 'should receive key in response' do
      allow(OverlayPublisher::Github).to receive(:register_webhooks).and_return(true)
      post '/register', payload
      last_response.should be_ok
      response = JSON.parse(last_response.body)
      expect(response['publish_key']).to eq("overlay_publisher_test_org_test_repo")
    end
  end
end