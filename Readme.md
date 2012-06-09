This script adds the capability to auto-confirm new members on [cobot](http://cobot.me).

It does that by subscribing to cobot's [webhooks api](https://www.cobot.me/pages/webhooks-api) and waiting for new memberships being created. If a new membership is created, it will be confirmed immediately.

### Getting Started

* This script uses the cobot API to connect to cobot - for that it needs an OAuth2 access token (see below)
* This script exposes a single API endpoint for the cobot webhooks API

If you just want to use the functionality please contac Cobot – we run our own instance of this script and can add you to it. You don't have to install it yourself.

#### Getting an access token

* Register your app at https://www.cobot.me/oauth2_clients/new and get the client id
* Go to <https://www.cobot.me/oauth2/authorize?client_id=$CLIENT_ID$&scope=read%20write&response_type=token&redirect_uri=http://localhost> (replacing $CLIENT_ID$ with the actual client id from step 1)
* Press `grant`
* Copy the token from the url in your browser

#### Deploying on heroku

Clone the source code and cd into the directoy. Install ruby and the heroku gem. Then:

    heroku create <random app name> --stack cedar
    heroku config:add RACK_ENV=production
    git push heroku master
    heroku ps:scale web=1 # start the web app
    heroku run console
    require './autoconfirm'
    DataMapper.auto_migrate! # create database tables. only do this once as it wipes your database
    Subscription.new(space_subdomain: <your-cobot-space-subdomain>,
      access_token: <access-token>).subscribe

#### Running on your local machine

Clone the source code and cd into the directoy. Then:

    bundle
    ruby autoconfirm.rb
