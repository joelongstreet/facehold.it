fs                  = require 'fs'
knox                = require 'knox'
request             = require 'request'
path                = require 'path'
as3_bucket          = 'faceholder'
local_photo_path    = "#{path.dirname(process.mainModule.filename)}/public/img"
knox_client         = knox.createClient
    key                 : process.env.S3_KEY
    secret              : process.env.S3_SECRET
    bucket              : as3_bucket


class exports.Facebook

    constructor : (redis_client) ->
        @redis_client = redis_client


    create : (user_id, next) ->

        request
            method  : 'GET'
            url     : "https://graph.facebook.com/#{user_id}/picture?type=large"
            timeout : 5000
        , (err, res, body) =>

            if err then next('Sorry, either Facbook is taking too long or I\'m currently being rate limited :(')

            if res
                fb_image_path = res.socket.pair.cleartext._httpMessage.path

                # Test to see if it's the default male or female facebook photos
                if fb_image_path == '/static-ak/rsrc.php/v2/yL/r/HsTZSDw4avx.gif' || fb_image_path == '/static-ak/rsrc.php/v2/yp/r/yDnr5YfbJCH.gif'
                    return false
                else @save user_id, fb_image_path, next



    save : (user_id, fb_image_path, next) ->

        # Write photo to disk
        piped = request("https://fbcdn-profile-a.akamaihd.net/#{fb_image_path}").pipe(fs.createWriteStream("#{local_photo_path}/#{user_id}.jpg"))
        piped.on 'error', (pipe_err) =>
            console.error 'could not write photo from facebook to file system', pipe_err

        # Save photo to database
        console.log 'borrowed another facebook photo!!!'
        piped.on 'close', =>
            knox_client.putFile piped.path, "#{user_id}.jpg", (err, res) =>
                if err then console.error 'error writing to s3 server', err
                
                # Delete the file From disk
                fs.unlink "#{local_photo_path}/#{user_id}.jpg", (delete_err) ->
                    if delete_err then console.error 'could not clean up file', delete_err

                # Let Redis know we got a new one for it
                @redis_client.lpush 'friends', user_id, (redis_err, redis_res) ->
                    if redis_err
                        next("could not write to remote redis server, #{redis_err}")
                    data =
                        user_id     : user_id
                        as3_path    : "https://s3.amazonaws.com/faceholder/#{user_id}.jpg"

                    if next then next(false, data)


    get_token : (next) ->
        token_path = 'https://graph.facebook.com/oauth/access_token?client_id=437279489672493&client_secret=23b75697bade006a53a52bebf6d44b1e&grant_type=client_credentials'

        request.get token_path, (err, res, body) ->
            if !err
                token_parts = body.split('access_token=')
                if next then next(token_parts[1])


    get_my_id : (token, next) ->
        me_url = "https://graph.facebook.com/me?access_token=#{encodeURIComponent(token)}"
        request.get me_url, (err, res, body) ->
            response = JSON.parse(body)
            console.log body
            next(response.id)