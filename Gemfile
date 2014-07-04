source 'http://rubygems.org'

ruby '2.1.2'

gem 'oauth2'
gem 'rake'
gem 'sinatra'
gem 'rack-test'
gem 'pg'
gem 'data_mapper'
gem 'dm-postgres-adapter'
gem 'json'

group :production do
  gem 'puma'
end

group :development do
  gem 'rspec'
end

group :test do
  gem 'webmock', require: 'webmock/rspec'
end
