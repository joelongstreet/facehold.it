redis         = require 'redis'
config        = require '../config'
env           = config()
redis_client  = redis.createClient(3322, '50.30.35.9')

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
