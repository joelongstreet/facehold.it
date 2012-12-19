fs              = require 'fs'
knox            = require 'knox'
request         = require 'request'
knox_client     = knox.createClient
    key         : process.env.S3_KEY
    secret      : process.env.S3_SECRET
    bucket      : 'faceholder'


face_job  = (next) ->
    rando       = Math.floor(Math.random() * 1000000000) + 1
    fb_req      = "https://graph.facebook.com/#{rando}/picture?type=large"

    request
        method  : 'GET'
        url     : fb_req
        timeout : 1500
    , (err, res, body) ->

        if err then console.error 'rate limiting from facebook: ', err

        if res
            image_path = res.socket.pair.cleartext._httpMessage.path

            if image_path == '/static-ak/rsrc.php/v2/yL/r/HsTZSDw4avx.gif' || image_path == '/static-ak/rsrc.php/v2/yp/r/yDnr5YfbJCH.gif'
                return false
            else
                piped = request("https://fbcdn-profile-a.akamaihd.net/#{image_path}").pipe(fs.createWriteStream("#{__dirname}/public/fb_images/#{rando}.jpg"))
                piped.on 'error', (pipe_err) ->
                    console.error 'could not write photo from facebook to file system', pipe_err
                piped.on 'close', ->
                    knox_client.putFile piped.path, "#{rando}.jpg", (err, res) ->
                        if err then console.error 'error writing to s3 server', err
                        else
                            fs.unlink "#{__dirname}/public/fb_images/#{rando}.jpg", (delete_err) ->
                                if delete_err then console.error 'could not clean up file', delete_err
                            next rando


module.exports = face_job