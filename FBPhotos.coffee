as3_bucket      = 'faceholder'
fs              = require 'fs'
knox            = require 'knox'
request         = require 'request'
knox_client     = knox.createClient
    key         : process.env.S3_KEY
    secret      : process.env.S3_SECRET
    bucket      : as3_bucket


class exports.FBPhotos

    constructor : (redis_client) ->
        @poop = true
        @redis_client = redis_client


    create_photo : (user_id, next) ->

        request
            method  : 'GET'
            url     : "https://graph.facebook.com/#{user_id}/picture?type=large"
            timeout : 5000
        , (err, res, body) =>

            if err then next('Sorry, I\'m currently being rate limited by Facebook :(')

            if res
                fb_image_path = res.socket.pair.cleartext._httpMessage.path

                # Test to see if it's the default male or female facebook photos
                if fb_image_path == '/static-ak/rsrc.php/v2/yL/r/HsTZSDw4avx.gif' || fb_image_path == '/static-ak/rsrc.php/v2/yp/r/yDnr5YfbJCH.gif'
                    return false
                else @save_facebook_photo user_id, fb_image_path, next



    save_facebook_photo : (user_id, fb_image_path, next) ->

        # Write photo to disk
        piped = request("https://fbcdn-profile-a.akamaihd.net/#{fb_image_path}").pipe(fs.createWriteStream("#{__dirname}/public/fb_images/#{user_id}.jpg"))
        piped.on 'error', (pipe_err) =>
            console.error 'could not write photo from facebook to file system', pipe_err

        # Save photo to database
        piped.on 'close', =>
            knox_client.putFile piped.path, "#{user_id}.jpg", (err, res) =>
                if err then console.error 'error writing to s3 server', err
                
                # Delete the file From disk
                fs.unlink "#{__dirname}/public/fb_images/#{user_id}.jpg", (delete_err) ->
                    if delete_err then console.error 'could not clean up file', delete_err

                # Let Redis know we got a new one for it
                @redis_client.lpush 'friends', user_id, (redis_err, redis_res) ->
                    if redis_err then console.error 'could not write to remote redis server', redis_err
                    else console.log "Successfully borrowed another FB Photo #{user_id}"

                    data =
                        user_id     : user_id
                        as3_path    : "https://s3.amazonaws.com/faceholder/#{user_id}.jpg"

                    if next then next(null, data)