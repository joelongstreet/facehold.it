class exports.Photos 

    constructor : (@redis_client) ->

    count       : (next) ->
        @redis_client.llen 'friends', (err, res) ->
            console.log "I currently have #{res} photos for you to choose from"
            if err
                console.error "could not get record length from database #{err}"
            else 
                if next then next(res)


    make_url    : (max, next) ->
        rando = Math.floor(Math.random() * max)
        @redis_client.lindex 'friends', rando, (err, res) ->
            if err then console.error "could not find record in database #{err}"
            else next(res)

