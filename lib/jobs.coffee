photos    = require './photos'
facebook  = require './facebook'

exports.fetch_and_save_random_facebook_users = ->

    catch_errors = (err) ->
        console.log err

    test_and_save = (user) ->
        if facebook.pic_is_valid(user.url) then photos.save user
        else console.log 'found default pic'

    run = ->
        user_id = Math.floor(Math.random() * 1000000000) + 1
        facebook.get_user(user_id).then(test_and_save).fail(catch_errors)

    setInterval(run, 1000)
