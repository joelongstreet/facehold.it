q         = require 'q'
request   = require 'request'



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



exports.get_token = (next) ->
    token_path = 'https://graph.facebook.com/oauth/access_token?client_id=437279489672493&client_secret=23b75697bade006a53a52bebf6d44b1e&grant_type=client_credentials'

    request.get token_path, (err, res, body) ->
        if !err
            token_parts = body.split('access_token=')
            if next then next(token_parts[1])



exports.get_my_id = (token, next) ->
    me_url = "https://graph.facebook.com/me?access_token=#{encodeURIComponent(token)}"
    request.get me_url, (err, res, body) ->
        response = JSON.parse(body)
        console.log body
        next(response.id)
