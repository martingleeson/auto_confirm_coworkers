require 'rubygems'
require 'bundler'
Bundler.require

class Subscription
  include DataMapper::Resource

  property :id, Serial
  property :space_subdomain, String
  property :access_token, String, length: 256
  property :plan, String

  def subscribe
    save!
    oauth.post "https://#{space_subdomain}.cobot.me/api/subscriptions", body: {
      event: 'created_membership', callback_url: "https://#{Autoconfirm.host}/#{space_subdomain}/membership_notification"}
  end

  def confirm_membership(membership_url)
    if should_confirm?(membership_url)
      oauth.post "#{membership_url}/confirmation"
    end
  end

  private

  def should_confirm?(url)
    if plan
      JSON.parse(oauth.get(url).body)['plan']['name'] == plan
    else
      true
    end
  end

  def oauth
    @oauth ||= OAuth2::AccessToken.new(client, access_token)
  end

  def client
    @client ||= OAuth2::Client.new(
      nil,
      nil, {
        :ssl => {
          :ca_file => 'cacert.pem'
        }
      }
    )
  end
end

class Autoconfirm < Sinatra::Base
  configure do
    DataMapper.finalize
  end

  configure(:test) do
    DataMapper.setup(:default, 'postgres://@localhost/autoconfirm_test')
    DataMapper::Logger.new(STDOUT, :debug)
    set :host, 'example.com'
  end

  configure(:production) do
    DataMapper.setup(:default, ENV['DATABASE_URL'])
    set :host, 'cobot-autoconfirm.herokuapp.com'
  end

  post '/:space_subdomain/membership_notification' do
    subscription = Subscription.first(space_subdomain: params[:space_subdomain])
    url = JSON.parse(request.body.read)['url']
    subscription.confirm_membership url
  end
end
