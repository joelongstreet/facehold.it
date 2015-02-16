request     = require 'request'
fs          = require 'fs'
analytics   = require 'nodealytics'
config      = require '../config'
facebook    = require './facebook'
photos      = require './photos'
env         = config()


fb_locales  = JSON.parse(fs.readFileSync('./data/fb_locales.js','utf-8'))
analytics   = analytics.initialize 'UA-3920837-11', 'faceholdit.jit.su'



exports.home = (req, res) =>
    if req.headers.referrer then res.redirect '/pic'
    else res.redirect '/25'



exports.pic = (req, res) =>
    photos.get_one (id) =>
        res.redirect "https://s3.amazonaws.com/faceholder/#{id}.jpg"
        # analytics.trackPage 'Picture', 'picture'



exports.add_user = (req, res) =>
    facebook.create req.params.fbid, (err, data) ->
        if err
            res.render 'error', {error : err}
        else
            res.render 'new_user_added', { uid : data.user_id, path : data.as3_path }



exports.add_me = (req, res) =>
    facebook.get_token (token) =>
        facebook.get_my_id (token), (user_id) =>
            facebook.create user_id, (err, data) ->
                if err
                    res.render 'error', {error : err}
                else
                    res.render 'new_user_added', { uid : data.user_id, path : data.as3_path }



exports.number = (req, res) =>
    if req.params.number > 100
        res.render 'max'
    else
        photos.get_some(req.params.number).then (photo_urls) ->
          res.render 'photos', photos : photo_urls



exports.get_user = (req, res) =>
    res.redirect "https://s3.amazonaws.com/faceholder/#{req.params.id}.jpg"



exports.hubot = (req, res) =>
    photos.count (err, count) =>
        photos.make_random_url count, (err, id) =>

            fb_req      = "https://graph.facebook.com/#{id}"

            request
                method  : 'GET'
                url     : fb_req
                timeout : 1500
            , (err, resp, body) =>

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
