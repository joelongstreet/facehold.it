express     = require 'express'
path        = require 'path'
stylus      = require 'stylus'
redis       = require 'redis'
bootstrap   = require 'bootstrap-stylus'
nodefly     = require 'nodefly'
{Routes}    = require './controllers/Routes'

port        = process.env.PORT || 3000
env         = process.env.environment || 'development'
app         = express()

redis_client= redis.createClient(2586, '50.30.35.9')
routes      = new Routes redis_client

nodefly.profile 'f2d55ddfaa41a91e73af49670dd71675', ['Facehold.it', process.env.SUBDOMAIN]

# --> Config 
app.use require('connect-assets')()
app.use express.static path.join __dirname, 'public'
    
app.set 'views', path.join __dirname, 'views'
app.set 'view engine', 'jade'
# -->


# --> Conenct to Redis
redis_client.auth process.env.REDIS_PASS, (err) ->
    if process.env.GETPHOTOS
        # Go Borrow Some Facebook Photos every so often
        setInterval (-> 
            rando = Math.floor(Math.random() * 1000000000) + 1
            fb_photos.create rando, ->
                return false
        ), 1000
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