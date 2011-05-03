require 'rubygems'
require 'bundler/setup'
require 'oauth2'
require 'json'

class Application
  
  def initialize(subdomain,space)
    @subdomain = subdomain
    @space = space
  end
  
  def client
    OAuth2::Client.new(
      nil,
      nil, {
        :parse_json => true,
        :site => "https://#{@subdomain}.cobot.me",
        :ssl => {
          :ca_file => 'cacert.pem'
        }
      }
    )
  end

  def run
    cobot_api = OAuth2::AccessToken.new(client, @space['access_token'])
    memberships = cobot_api.get("/api/memberships")
            
    memberships.each do |membership|
      if membership['confirmed_at'].nil?
        cobot_api.post("/api/memberships/#{membership['id']}/confirmation")
      end
    end
    puts 'finished!'
    true
  end
  
end



#starting app
begin

  cobot_spaces = JSON.parse(ENV['COBOT_SPACES'])
  cobot_spaces.each do |subdomain,space|
    app = Application.new(subdomain,space)
    app.run
  end

rescue => e
  
  puts "Error: #{e}"
    
end



