q                 = require 'q'
fs                = require 'fs'
knox              = require 'knox'
request           = require 'request'
path              = require 'path'
events            = require 'events'
cache             = require './cache'
config            = require '../config'
local_photo_path  = "#{path.dirname(process.mainModule.filename)}/tmp"
env               = config()
knox_client       = knox.createClient
    key                 : env.S3_KEY
    secret              : env.S3_SECRET
    bucket              : env.AS3_BUCKET


exports.get_one = (next) ->
    cache.get_length().then (count) ->
      randomIndex = Math.floor(Math.random() * count)
      cache.get_item_by_index(randomIndex).then(next)


exports.get_some = (number_requested) ->
    deferred    = q.defer()
    photo_urls  = []
    index       = 0
    is_ready    = new events.EventEmitter()

    is_ready.once 'ready', ->
        deferred.resolve photo_urls

    cache.get_length().then (count) ->
        while index < number_requested
            random_index = Math.floor(Math.random() * count)
            cache.get_item_by_index(random_index).then (id) ->
                photo_urls.push id
                if photo_urls.length >= number_requested - 1
                    is_ready.emit 'ready'
            index++

    deferred.promise


add_to_S3 = (local_path, remote_path) ->
    deferred = q.defer()

    knox_client.putFile local_path, remote_path, (err, res) =>
        if err then console.error 'could not add to s3', err
        else deferred.resolve()

    deferred.promise


exports.save = (user) ->
    deferred = q.defer()

    piped = request("#{user.url}")
      .pipe(fs.createWriteStream("#{local_photo_path}/#{user.id}.jpg"))

    piped.on 'error', err ->
      deferred.reject(err)

    piped.on 'close', ->
      add_to_S3(piped.path, "#{user.id}.jpg").then (photo_url) ->
        fs.unlink "#{local_photo_path}/#{user.id}.jpg"
        cache.add user_id
        console.log "added user #{user.id}"
        deferred.resolve
            id    : user.id
            url   : "https://s3.amazonaws.com/faceholder/#{user.id}.jpg"

    deferred.promise
