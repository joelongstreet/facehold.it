request     = require 'request'
fs          = require 'fs'
events      = require 'events'
analytics   = require 'nodealytics'
{Facebook}  = require './Facebook'
{Photos}    = require './Photos'


class exports.Routes

    constructor : (@redis_client) ->
        @facebook   = new Facebook @redis_client
        @photos     = new Photos @redis_client
        @fb_locales = JSON.parse(fs.readFileSync('./data/fb_locales.js','utf-8'))
        @analytics  = analytics.initialize 'UA-3920837-11', 'faceholdit.jit.su'

        if process.env.GETPHOTOS
            
            # Go Borrow Some Facebook Photos every so often
            setInterval (=>
                rando = Math.floor(Math.random() * 1000000000) + 1
                @facebook.create rando, ->
                    return false
            ), 1000


    home        : (req, res) =>
        if req.headers.referrer then res.redirect '/pic'
        else res.redirect '/25'


    pic         : (req, res) =>
        @photos.count (err, count) =>
            if err then res.render 'error', {error : err}
            else
                @photos.make_random_url count, (err, id) =>
                    if err then res.render 'error', {error : err}
                    else
                        @analytics.trackPage 'Picture', 'picture'
                        res.redirect "https://s3.amazonaws.com/faceholder/#{id}.jpg"


    add_user    : (req, res) =>
        @facebook.create req.params.fbid, (err, data) ->
            if err
                res.render 'error', {error : err}
            else
                res.render 'new_user_added', { uid : data.user_id, path : data.as3_path }


    add_me      : (req, res) =>
        @facebook.get_token (token) =>
            @facebook.get_my_id (token), (user_id) =>
                @facebook.create user_id, (err, data) ->
                    if err
                        res.render 'error', {error : err}
                    else
                        res.render 'new_user_added', { uid : data.user_id, path : data.as3_path }


    number      : (req, res) =>
        if req.params.number > 100
            res.render 'max'
        else
            photo_urls  = []
            index       = 0
            @photos.count (err, count) =>
                is_ready = new events.EventEmitter()
                is_ready.once 'ready', ->
                    res.render 'photos', photos : photo_urls

                while index < req.params.number
                    @photos.make_random_url count, (err, id) ->
                        if err then console.log 'error fetching photo'
                        else photo_urls.push id

                        if photo_urls.length == req.params.number - 1
                            is_ready.emit 'ready'

                    index++


    get_user        : (req, res) =>
        res.redirect "https://s3.amazonaws.com/faceholder/#{req.params.id}.jpg"


    hubot       : (req, res) =>
        @photos.count (err, count) =>
            @photos.make_random_url count, (err, id) =>

                fb_req      = "https://graph.facebook.com/#{id}"

                request
                    method  : 'GET'
                    url     : fb_req
                    timeout : 1500
                , (err, resp, body) =>

                    fb_body = JSON.parse(body)
                   
                    locale == 'American'
                    for location in @fb_locales
                        if location.fb_code == fb_body.locale
                            locale = location.nationality

                    res.send
                        id          : fb_body.id
                        name        : fb_body.name
                        gender      : fb_body.gender
                        url         : fb_body.link
                        nationality : locale
                        image       : "https://s3.amazonaws.com/faceholder/#{id}.jpg"