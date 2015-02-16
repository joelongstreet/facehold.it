q           = require 'q'
redis       = require 'redis'
config      = require '../config'
client      = redis.createClient(3775, '50.30.35.9')
env         = config()

client.auth env.REDIS_PASS


exports.clear = ->
    client.del 'friends', (err, res) ->
        if(err) then console.log err
        else console.log res


exports.add = (user_id) ->
    client.lpush 'friends', user_id


exports.get_length = ->
    deferred = q.defer()

    client.llen 'friends', (err, res) ->
        if err then deferred.reject(err)
        else deferred.resolve(res)

    deferred.promise


exports.get_item_by_index = (index) ->
    deferred = q.defer()

    client.lindex 'friends', index, (err, res) ->
        if err || res == 'undefined'
          deferred.reject "could not find record in database #{err || res}"
        else deferred.resolve res

    deferred.promise
