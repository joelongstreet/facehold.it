express     = require 'express'
path        = require 'path'
stylus      = require 'stylus'
bootstrap   = require 'bootstrap-stylus'
config      = require './config'
jobs        = require './lib/jobs'
routes      = require './lib/routes'

env         = config()
port        = env.PORT || 3000
mode        = env.mode || 'development'
app         = express()

# --> Config
app.use require('connect-assets')()
app.use express.static path.join __dirname, 'public'

app.set 'views', path.join __dirname, 'views'
app.set 'view engine', 'jade'
# -->

app.get '/', routes.home
app.get '/pic', routes.pic
app.get '/:number', routes.number
app.get '/add/me', routes.add_me
app.get '/add/:fbid', routes.add_user
app.get '/user/:id', routes.get_user


# Go Borrow Some Facebook Photos every so often
if env.GETPHOTOS
    jobs.fetch_and_save_random_facebook_users()

app.listen port
console.log "server running on port #{port} in #{mode} environment"
