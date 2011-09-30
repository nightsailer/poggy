# Poggy - Padrino components to make comaptible with doggy apps

# Installaion #

Just include it in your project's `Gemfile` with Bundler:

    gem 'poggy', :git => 'git://github.com/nightsailer/poggy.git'

then, run bundle:
    
    $ bundle install

# Usage #

**Warning: This gem is not usable for everyone, just help us to port our private doggy php framework projects to padrino powered apps.**

## Session - MongoDB store for rack session
In your app.rb:

    disable 'sessions' # This is will turn off cookie based session
    # turn on poggy session, session will stored in mongodb
    use Poggy::Session,
        # session collection
        :session_col => Mongoid::database['session'],
        # session key, refere your doggy project sid, default is app_id concat with '_sid'
        :key => 'doggy_sid'

## Gridfs asset middleware

This middleware handle assets stored in mongodb gridfs. This app just handle assets by its object id!

In your config/apps.rb

    Padrino.mount('Poggy::GridfsApp').to('/gridfs')
    #or mulitple asset hosts support
    Padrino.mount('Poggy::GridfsApp').to('/gridfs').host(/img.*\.nightsailer.com/)


Now, it will serve assets like:
    
    get /gridfs/4e645d59b46ab7b627000000.jpg
    get /gridfs/4e645d59b46ab7b627000000.png


    








