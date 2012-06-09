require 'spec_helper'

describe 'setting up auto-confirm' do
  before(:each) do
    stub_request(:post, "https://co-up.cobot.me/api/subscriptions")
    stub_request(:post, "https://co-up.cobot.me/api/memberships/123/confirmation")
  end

  it 'subscribes to the created_membership event' do
    subscription = Subscription.new(space_subdomain: 'co-up',
      access_token: '12345').subscribe

    WebMock.should have_requested(:post, 'https://co-up.cobot.me/api/subscriptions'
      ).with(
        headers: {'Authorization' => 'Bearer 12345'},
        body: {event: 'created_membership',
               callback_url: "https://#{Autoconfirm.host}/co-up/membership_notification"}
      )
  end

  it 'confirms a new membership' do
    Subscription.create!(space_subdomain: 'co-up',
      access_token: '12345')

    post '/co-up/membership_notification', {url: 'https://co-up.cobot.me/api/memberships/123'}.to_json

    last_response.status.should eql(200)
    WebMock.should have_requested(:post, 'https://co-up.cobot.me/api/memberships/123/confirmation'
      ).with(headers: {'Authorization' => 'Bearer 12345'})
  end
end
