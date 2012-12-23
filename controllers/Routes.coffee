request     = require 'request'
fs          = require 'fs'
events      = require 'events'
{Facebook}  = require './Facebook'
{Photos}    = require './Photos'

class exports.Routes

    constructor : (@redis_client) ->
        @facebook   = new Facebook @redis_client
        @photos     = new Photos @redis_client
        @fb_locales = JSON.parse(fs.readFileSync('./data/fb_locales.js','utf-8'))


    home        : (req, res) =>
        count = @photos.count (how_many) ->
            console.log how_many
        if req.headers.referrer then res.redirect '/pic'
        else res.redirect '/25'


    pic         : (req, res) =>
        @photos.count (count) =>
            @photos.make_url count, (id) =>
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
        else if req.params.number == '1'
            res.redirect '/pic'
        else
            photo_urls  = []
            index       = 0
            @photos.count (count) =>
                is_ready = new events.EventEmitter()
                is_ready.once 'ready', ->
                    res.render 'photos', photos : photo_urls

                while index < req.params.number
                    @photos.make_url count, (id) ->
                        photo_urls.push id
                        if photo_urls.length == req.params.number - 1
                            is_ready.emit 'ready'

                    index++


    hubot       : (req, res) =>
        @photos.count (count) =>
            @photos.make_url count, (id) =>

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