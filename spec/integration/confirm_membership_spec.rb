require 'spec_helper'

describe 'setting up auto-confirm' do
  before(:each) do
    stub_request(:post, "https://co-up.cobot.me/api/subscriptions")
    stub_request(:post, "https://co-up.cobot.me/api/memberships/123/confirmation")
    Subscription.destroy
  end

  it 'subscribes to the created_membership and updated_payment_method events' do
    subscription = Subscription.new(space_subdomain: 'co-up',
      access_token: '12345').subscribe

    expect(a_request(:post, 'https://co-up.cobot.me/api/subscriptions'
      ).with(
        headers: {'Authorization' => 'Bearer 12345'},
        body: {event: 'created_membership',
               callback_url: "https://#{Autoconfirm.host}/co-up/membership_notification"}
      )).to have_been_made

    expect(a_request(:post, 'https://co-up.cobot.me/api/subscriptions'
      ).with(
        headers: {'Authorization' => 'Bearer 12345'},
        body: {event: 'updated_payment_method',
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

  context 'with a given plan' do
    before(:each) do
      Subscription.create!(space_subdomain: 'co-up',
        access_token: '12345', plan: 'Day Pass')
    end

    it 'confirms new memberships on the given plan' do
      stub_request(:get, 'https://co-up.cobot.me/api/memberships/123')
        .with(headers: {'Authorization' => 'Bearer 12345'})
        .to_return(body: {plan: {name: 'Day Pass'}}.to_json)

      post '/co-up/membership_notification', {url: 'https://co-up.cobot.me/api/memberships/123'}.to_json

      expect(last_response.status).to eql(200)
      expect(a_request(:post, 'https://co-up.cobot.me/api/memberships/123/confirmation'
        ).with(headers: {'Authorization' => 'Bearer 12345'})).to have_been_made
    end

    it 'does not confirm new memberships on another but the given plan' do
      stub_request(:get, 'https://co-up.cobot.me/api/memberships/123')
        .with(headers: {'Authorization' => 'Bearer 12345'})
        .to_return(body: {plan: {name: 'Part Time'}}.to_json)

      post '/co-up/membership_notification', {url: 'https://co-up.cobot.me/api/memberships/123'}.to_json

      expect(last_response.status).to eql(200)
      expect(a_request(:post, 'https://co-up.cobot.me/api/memberships/123/confirmation')).to_not have_been_made
    end
  end

  context 'with automated payment method required' do
    before(:each) do
      Subscription.create!(space_subdomain: 'co-up',
        access_token: '12345', require_automated_payment_method: true)
    end

    it 'confirms memberships with an automated payment method' do
      stub_request(:get, 'https://co-up.cobot.me/api/memberships/123')
        .with(headers: {'Authorization' => 'Bearer 12345'})
        .to_return(body: {payment_method: {automated: true}}.to_json)

      post '/co-up/membership_notification', {url: 'https://co-up.cobot.me/api/memberships/123'}.to_json

      expect(last_response.status).to eql(200)
      expect(a_request(:post, 'https://co-up.cobot.me/api/memberships/123/confirmation')).to have_been_made
    end

    it 'does not confirm memberships without no payment method' do
      stub_request(:get, 'https://co-up.cobot.me/api/memberships/123')
        .with(headers: {'Authorization' => 'Bearer 12345'})
        .to_return(body: {payment_method: nil}.to_json)

      post '/co-up/membership_notification', {url: 'https://co-up.cobot.me/api/memberships/123'}.to_json

      expect(last_response.status).to eql(200)
      expect(a_request(:post, 'https://co-up.cobot.me/api/memberships/123/confirmation')).to_not have_been_made
    end

    it 'does not confirm memberships without a non-automated payment method' do
      stub_request(:get, 'https://co-up.cobot.me/api/memberships/123')
        .with(headers: {'Authorization' => 'Bearer 12345'})
        .to_return(body: {payment_method: {automated: false}}.to_json)

      post '/co-up/membership_notification', {url: 'https://co-up.cobot.me/api/memberships/123'}.to_json

      expect(last_response.status).to eql(200)
      expect(a_request(:post, 'https://co-up.cobot.me/api/memberships/123/confirmation')).to_not have_been_made
    end
  end
end
