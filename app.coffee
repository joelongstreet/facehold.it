express     = require 'express'
path        = require 'path'
{Routes}    = require './controllers/Routes'
port        = process.env.PORT || 3000
env         = process.env.environment || 'development'
app         = express()
routes      = new Routes()


# - Config - #
app.use require('connect-assets')()
app.use express.static path.join __dirname, 'public'
    
app.set 'views', path.join __dirname, 'views'
app.set 'view engine', 'jade'
# // - // #


# - Routes - #
app.get '/', routes.home
app.get '/pic', routes.pic
app.get '/hubot', routes.hubot
app.get '/:number', routes.number
app.get '/add/me', routes.add_me
app.get '/add/:fbid', routes.add_user
app.get '/user/:id', routes.get_user
# // - // #


# - Start App - #
app.listen port
console.log "server running on port #{port} in #{env} environment"
# // - // #