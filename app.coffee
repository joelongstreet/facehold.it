#517885548
express     = require 'express'
path        = require 'path'
fs          = require 'fs'
stylus      = require 'stylus'
request     = require 'request'
redis       = require 'redis'
bootstrap   = require 'bootstrap-stylus'
emitter     = require('events').EventEmitter
{FBPhotos}  = require './FBPhotos'

port        = process.env.PORT || 3000
env         = process.env.environment || 'development'
app         = express()

fb_photos   = null


# --> Config 
app.use require('connect-assets')()
app.use express.static path.join __dirname, 'public'
    
app.set 'views', path.join __dirname, 'views'
app.set 'view engine', 'jade'
# --> End Config



# --> Auth with Redois
redis_client    = redis.createClient(2586, '50.30.35.9')
redis_client.auth process.env.REDIS_PASS, (err) ->

    fb_photos = new FBPhotos(redis_client)
    console.log 'redis authed'
    if env != 'production'
        # Go Get Facebook Photos every 3 seconds
        get_photo_int   = 0
        get_photo_int = setInterval (-> 
            rando = Math.floor(Math.random() * 1000000000) + 1
            fb_photos.create_photo rando, ->
        ), 3000
# -->



# --> Make a photo random photo url
make_photo_url = (max, next) ->
    rando = Math.floor(Math.random() * max)
    redis_client.lindex 'friends', rando, (err, res) ->
        if err then console.error "could not find record in database #{err}"
        else next(res)
# --> End



# --> How many photos do I have...
get_photo_count = (next) ->
    redis_client.llen 'friends', (err, res) ->
        console.log "I currently have #{res} photos for you to choose from"
        if err
            console.error "could not get record length from database #{err}"
        else 
            if next then next(res)
# --> End



app.get '/', (req, res, next) ->
    if req.headers.referrer then res.redirect '/pic'
    else res.redirect '/25'


app.get '/pic', (req, res, next) ->
    get_photo_count (photo_count) ->
        make_photo_url photo_count, (id) ->
            res.redirect "https://s3.amazonaws.com/faceholder/#{id}.jpg"



# Convert af_ZA to Afrikaans, az_AZ to Azerbaijani.. etc.
fb_locales = JSON.parse(fs.readFileSync('./fb_locales.js','utf-8'))

# --> Hubot script to serve random people
app.get '/hubot', (req, res, next) ->
    get_photo_count (photo_count) ->
        make_photo_url photo_count, (id) ->

            fb_req      = "https://graph.facebook.com/#{id}"

            request
                method  : 'GET'
                url     : fb_req
                timeout : 1500
            , (err, resp, body) ->

                fb_body = JSON.parse(body)
               
                locale == 'American'
                for location in fb_locales
                    if location.fb_code == fb_body.locale
                        locale = location.nationality

                res.send
                    id          : fb_body.id
                    name        : fb_body.name
                    gender      : fb_body.gender
                    url         : fb_body.link
                    nationality : locale
                    image       : "https://s3.amazonaws.com/faceholder/#{id}.jpg"
# --> End


app.get '/:number', (req, res, next) ->

    if req.params.number > 100 then res.render 'max'
    else if req.params.number == '1' then res.redirect '/pic'

    else
        photo_urls  = []
        index       = 0

        get_photo_count (photo_count) =>
            is_ready = new emitter()
            is_ready.once 'ready', ->
                res.render 'photos', photos : photo_urls

            while index < req.params.number

                make_photo_url photo_count, (id) ->
                    photo_urls.push id

                    if photo_urls.length == req.params.number - 1
                        is_ready.emit 'ready'

                index++


app.get '/add/:fbid', (req, res) ->
    fb_photos.create_photo req.params.fbid, (err, data) ->
        if err
            res.render 'error', {error : err}
        else
            res.render 'new_user_added', { uid : data.user_id, path : data.as3_path }


app.listen port
console.log "server running on port #{port} in #{env} environment"