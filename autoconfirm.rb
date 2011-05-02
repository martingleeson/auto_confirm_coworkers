require 'rubygems'
require 'bundler/setup'
require 'oauth2'
require 'json'

# https://www.cobot.me/oauth2/authorize?client_id=5e0cf837aad41eec609aedfb32f81c6e&scope=read%20write&response_type=token&redirect_uri=http://localhost/test

APP_KEY = 'YOUR_APP_KEY'
APP_SECRET = 'YOUR_APP_SECRET'
APP_SCOPE = 'YOUR_SCOPE'
APP_URL = 'YOUR_APP_URL'

PROVIDER_URL = 'https://www.cobot.me'
PROVIDER_AUTHORIZE_PATH = '/oauth2/authorize'
PROVIDER_ACCESS_PATH = '/oauth2/access_token'

USER_ACCESS_TOKEN = 'YOUR_USER_ACCESS_TOKEN'
USER_SPACE_SUBDOMAIN = 'YOUR_SUBDOMAIN'

puts 'started!'

class Application
  
  def client
    OAuth2::Client.new(APP_KEY, APP_SECRET, {
        :access_token_method => :post,
        :authorize_path => PROVIDER_AUTHORIZE_PATH,
        :access_token_path => PROVIDER_ACCESS_PATH,
        :parse_json => true,
        :site => PROVIDER_URL,
        :ssl => {
          :ca_file => 'cacert.pem'
        }
    })
  end

  def run!
    cobot_api = OAuth2::AccessToken.new(client, USER_ACCESS_TOKEN)
    memberships = cobot_api.get("https://#{USER_SPACE_SUBDOMAIN}.cobot.me/api/memberships")
            
    memberships.each do |membership|
      if membership['confirmed_at'].nil?
        cobot_api.post("https://#{USER_SPACE_SUBDOMAIN}.cobot.me/api/memberships/#{membership['id']}/confirmation")
        puts "#{membership['user']['login']} confirmed."
      end
    end
    'finished!'
  end
  
end



#starting app
begin

app = Application.new
puts app.run!

rescue => e
  
  puts "Error: #{e}"
    
end



