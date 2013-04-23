var fs          = require('fs');
var request     = require('request');


var getToken = function(next){
    var baseURL     = 'https://graph.facebook.com/oauth/access_token?'
    var urlParams   = 'client_id=' + process.env.FB_ID + '&client_secret=' + process.env.FB_SECRET + '&grant_type=client_credentials';
    var tokenPath   = baseURL + urlParams;

    request.get(tokenPath, function(err, res, body){
        if(!err){
            tokenParts = body.split('access_token=');
            if(next) { next(tokenParts[1]) }
        }
    });
};

var getMyId = function(token, next){
    var meUrl = 'https://graph.facebook.com/me?access_token=' + encodeURIComponent(token);
    request.get(meUrl, function(err, res, body){
        response = JSON.parse(body);
        next(response.id)
    });
};

var steal = function(userId, next){
    request({
        method  : 'GET',
        url     : 'https://graph.facebook.com/' + userId + '/picture?type=large',
        timeout : 5000
    }, function(err, res, body){

        if(err) {
            console.log('rate limited :(');
        } else if (res) {
            next({
                userId  : userId,
                url     : res.socket.pair.cleartext._httpMessage.path
            });
        }
    });
};

exports.getToken = getToken;