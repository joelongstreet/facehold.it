express     = require 'express'
path        = require 'path'
stylus      = require 'stylus'
redis       = require 'redis'
bootstrap   = require 'bootstrap-stylus'
nodefly     = require 'nodefly'
config      = require './config'
{Routes}    = require './controllers/Routes'
{FB}        = require './controllers/Facebook'

env         = config()
port        = env.PORT || 3000
env         = env.environment || 'development'
app         = express()

redis_client= redis.createClient(2586, '50.30.35.9')
routes      = new Routes redis_client

nodefly.profile 'f2d55ddfaa41a91e73af49670dd71675', ['Facehold.it', env.SUBDOMAIN]

# --> Config
app.use require('connect-assets')()
app.use express.static path.join __dirname, 'public'

app.set 'views', path.join __dirname, 'views'
app.set 'view engine', 'jade'

redis_client.auth env.REDIS_PASS
# -->

app.get '/', routes.home
app.get '/pic', routes.pic
app.get '/hubot', routes.hubot
app.get '/:number', routes.number
app.get '/add/me', routes.add_me
app.get '/add/:fbid', routes.add_user
app.get '/user/:id', routes.get_user

app.listen port
console.log "server running on port #{port} in #{env} environment"
