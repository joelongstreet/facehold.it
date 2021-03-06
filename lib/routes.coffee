request     = require 'request'
fs          = require 'fs'
analytics   = require 'nodealytics'
config      = require '../config'
facebook    = require './facebook'
photos      = require './photos'
cache       = require './cache'
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
    facebook.get_token()
      .then(facebook.get_my_id)
      .then(facebook.get_user)
      .then(photos.save)
      .then (user) ->
          res.render 'new_user_added', user
      .reject (err) ->
          res.render 'error', { error : err }



exports.count = (req, res) ->
    cache.get_length().then (count) ->
        res.send total_photo_count : count



exports.number = (req, res) =>
    if req.params.number > 100
        res.render 'max'
    else
        photos.get_some(req.params.number).then (photo_urls) ->
          res.render 'photos', photos : photo_urls



exports.get_user = (req, res) =>
    res.redirect "https://s3.amazonaws.com/faceholder/#{req.params.id}.jpg"
