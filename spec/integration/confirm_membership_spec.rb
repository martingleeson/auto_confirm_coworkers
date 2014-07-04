require 'spec_helper'

describe 'setting up auto-confirm' do
  before(:each) do
    stub_request(:post, "https://co-up.cobot.me/api/subscriptions")
    stub_request(:post, "https://co-up.cobot.me/api/memberships/123/confirmation")
    Subscription.destroy
  end

  it 'subscribes to the created_membership event' do
    subscription = Subscription.new(space_subdomain: 'co-up',
      access_token: '12345').subscribe

    expect(a_request(:post, 'https://co-up.cobot.me/api/subscriptions'
      ).with(
        headers: {'Authorization' => 'Bearer 12345'},
        body: {event: 'created_membership',
               callback_url: "https://#{Autoconfirm.host}/co-up/membership_notification"}
      )).to have_been_made
  end

  it 'confirms a new membership' do
    Subscription.create!(space_subdomain: 'co-up',
      access_token: '12345')

    post '/co-up/membership_notification', {url: 'https://co-up.cobot.me/api/memberships/123'}.to_json

    expect(last_response.status).to eql(200)
    expect(a_request(:post, 'https://co-up.cobot.me/api/memberships/123/confirmation'
      ).with(headers: {'Authorization' => 'Bearer 12345'})).to have_been_made
  end

  it 'confirms new memberships on the given plan' do
    Subscription.create!(space_subdomain: 'co-up',
      access_token: '12345', plan: 'Day Pass')

    stub_request(:get, 'https://co-up.cobot.me/api/memberships/123')
      .with(headers: {'Authorization' => 'Bearer 12345'})
      .to_return(body: {plan: {name: 'Day Pass'}}.to_json)
    post '/co-up/membership_notification', {url: 'https://co-up.cobot.me/api/memberships/123'}.to_json

    expect(last_response.status).to eql(200)
    expect(a_request(:post, 'https://co-up.cobot.me/api/memberships/123/confirmation'
      ).with(headers: {'Authorization' => 'Bearer 12345'})).to have_been_made
  end

  it 'does not confirm new memberships on another but the given plan' do
    Subscription.create!(space_subdomain: 'co-up',
      access_token: '12345', plan: 'Day Pass')

    stub_request(:get, 'https://co-up.cobot.me/api/memberships/123')
      .with(headers: {'Authorization' => 'Bearer 12345'})
      .to_return(body: {plan: {name: 'Part Time'}}.to_json)
    post '/co-up/membership_notification', {url: 'https://co-up.cobot.me/api/memberships/123'}.to_json

    expect(last_response.status).to eql(200)
    expect(a_request(:post, 'https://co-up.cobot.me/api/memberships/123/confirmation')).to_not have_been_made
  end
end
