This script adds the capability to autoconfirm members on [cobot](http://cobot.me).

It does that by regularly checking a coworking space's members for unconfirmed memberships. If it finds unconfirmed memberships, they will be confirmed.

### Getting Started

* This script is built so that it runs as a cron job
* It uses the cobot API to connect to cobot - for that it needs an OAuth2 access token (see below)
* The easiest way to deploy is on heroku with the cron:daily addon installed


#### Getting an access token

* Register your app at https://www.cobot.me/oauth2_clients/new and get the client id
* Go to <https://www.cobot.me/oauth2/authorize?client_id=$CLIENT_ID$&scope=read%20write&response_type=token&redirect_uri=http://localhost> (replacing $CLIENT_ID$ with the actual client id from step 1)
* Press `grant`
* Copy the token from the url in your browser

#### Deploying on heroku

Clone the source code and cd into the directoy. Install ruby and the heroku gem. Then:
    
    heroku create <random app name>
    heroku addons:add cron:daily
    heroku config:add COBOT_SPACES='{"YOUR_SUBDOMAIN": {"access_token": "YOUR_ACCESS_TOKEN"}}'
    heroku stack:migrate bamboo-mri-1.9.2
    git push heroku master

#### Running on your local machine

Clone the source code and cd into the directoy. Then:

    export COBOT_SPACES='{"YOUR_SUBDOMAIN": {"access_token": "YOUR_ACCESS_TOKEN"}}'
    bundle install
    ruby autoconfirm.rb
