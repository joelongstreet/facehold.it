q         = require 'q'
request   = require 'request'
config    = require '../config'
env       = config()



exports.get_user = (user_id) ->
    deferred = q.defer()

    request
        method  : 'GET'
        url     : "https://graph.facebook.com/#{user_id}/picture?type=large"
        timeout : 5000
    , (err, res, body) =>
        if err then deferred.reject('rate limit')
        else if res && res.request then deferred.resolve
            url : res.request.href
            id  : user_id

    deferred.promise



exports.pic_is_valid = (remote_path) ->
  if remote_path.indexOf('.gif') == -1 then return true
  else return false



exports.get_token = ->
    deferred = q.defer()
    token_path = "https://graph.facebook.com/oauth/access_token?client_id=#{env.FACEBOOK_ID}&client_secret=#{env.FACEBOOK_SECRET}&grant_type=client_credentials"

    request.get token_path, (err, res, body) ->
        if err then deferred.reject(err)
        else
            token_parts = body.split('access_token=')
            deferred.resolve token_parts[1]

    deferred.promise



exports.get_my_id = (token) ->
    deferred = q.defer()

    me_url = "https://graph.facebook.com/me?access_token=#{token}"
    request.get me_url, (err, res, body) ->
        if(err) then deferred.reject(err)
        else
          response = JSON.parse(body)
          console.log(response)
          deferred.resolve(response.id)

    deferred.promise
