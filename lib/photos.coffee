q                 = require 'q'
fs                = require 'fs'
redis             = require 'redis'
knox              = require 'knox'
request           = require 'request'
path              = require 'path'
config            = require '../config'
env               = config()
local_photo_path  = "#{path.dirname(process.mainModule.filename)}/tmp"
redis_client      = redis.createClient(3322, '50.30.35.9')
knox_client       = knox.createClient
    key                 : env.S3_KEY
    secret              : env.S3_SECRET
    bucket              : env.AS3_BUCKET

redis_client.auth env.REDIS_PASS


exports.count = (next) ->
    redis_client.llen 'friends', (err, res) ->
        if err then next "could not get record length from database #{err}"
        else next(false, res)


exports.make_url = (index, next) ->
    redis_client.lindex 'friends', index, (err, res) ->
        if err || res == 'undefined'
            next "could not find record in database #{err}"
        else next(false, res)


exports.make_random_url = (max, next) ->
    rando = Math.floor(Math.random() * max)
    redis_client.lindex 'friends', rando, (err, res) ->
        if err || res == 'undefined'
            next "could not find record in database #{err}"
        else next false, res


delete_local_file = (file_path) ->
    # Delete the file From disk
    fs.unlink file_path, (err) ->
        if err then console.error 'could not clean up file', err


add_to_S3 = (local_path, remote_path) ->
    deferred = q.defer()

    knox_client.putFile local_path, remote_path, (err, res) =>
        if err then console.error 'could not add to s3', err
        else deferred.resolve()

    deferred.promise


write_to_redis = (user_id) ->
    redis_client.lpush 'friends', user_id, (err, res) ->
        if err then console.error 'could not write to redis', err


exports.save = (user_id, remote_path) ->
    # write photo to disk
    piped = request("#{remote_path}")
      .pipe(fs.createWriteStream("#{local_photo_path}/#{user_id}.jpg"))

    # notify redis + S3, delete local file
    piped.on 'close', =>
      add_to_S3(piped.path, "#{user_id}.jpg").then ->
        delete_local_file("#{local_photo_path}/#{user_id}.jpg")
        write_to_redis()
        console.log "sucesfully added user #{user_id}"
