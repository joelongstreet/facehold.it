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


exports.save = (user_id, remote_path) ->
    # write photo to disk
    piped = request("#{remote_path}")
      .pipe(fs.createWriteStream("#{local_photo_path}/#{user_id}.jpg"))

    # notify redis + S3, delete local file
    piped.on 'close', =>
      add_to_S3(piped.path, "#{user_id}.jpg").then ->
        fs.unlink "#{local_photo_path}/#{user_id}.jpg"
        cache.add user_id
        console.log "added user #{user_id}"
