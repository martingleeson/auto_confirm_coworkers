This script adds the capability to autoconfirm members on [cobot](http://cobot.me).

It does that by regularly checking a coworking space's members for unconfirmed memberships. If it finds unconfirmed memberships they will be confirmed.

### Getting Started

* this script is built so that it runs as a cron job
* it uses the cobot API to connect to cobot - for that it needs an OAuth2 access token (see below)
* the easiest way to deploy is on heroku with the cron:daily addon installed


#### getting an access token

* register your app https://www.cobot.me/oauth2_clients/new and get the client id
* go to <https://www.cobot.me/oauth2/authorize?client_id=$CLIENT_ID$&scope=read%20write&response_type=token&redirect_uri=http://localhost> (replacing $CLIENT_ID$ with the actual client id from step 1)
* press `grant`
* copy the token from the url in your browser

#### deploying on heroku

clone the source code and cd into the directoy. install ruby and the heroku gem. then:
    
    heroku create <random app name>
    heroku addons:add cron:daily
    heroku config:add COBOT_SPACES='{"YOUR_SUBDOMAIN": {"access_token": "YOUR_ACCESS_TOKEN"}}'
    heroku stack:migrate bamboo-mri-1.9.2
    git push heroku master

#### running on your local machine

clone the source code and cd into the directoy. then:

    export COBOT_SPACES='{"YOUR_SUBDOMAIN": {"access_token": "YOUR_ACCESS_TOKEN"}}'
    bundle install
    ruby autoconfirm.rb