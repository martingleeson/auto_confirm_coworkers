ENV['RACK_ENV'] = 'test'
require_relative '../autoconfirm'
require 'rspec'
require 'rack/test'
require 'webmock/rspec'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  conf.before(:all) do
    DataMapper.auto_migrate!
  end
end

def app
  Autoconfirm.new
end
