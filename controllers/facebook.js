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

var getMyId = function(next){
    getToken(function(token){
        var meUrl = 'https://graph.facebook.com/me?access_token=' + encodeURIComponent(token);
        request.get(meUrl, function(err, res, body){
            response = JSON.parse(body);
            if(next) { next(response.id); }
        });
    });
};

var steal = function(userId, next){
    request({
        method  : 'GET',
        url     : 'https://graph.facebook.com/' + userId + '/picture?type=large',
        timeout : 10000
    }, function(err, res, body){

        if(err) {
            console.log(err);
            console.log('rate limited :(');
        } else if (res) {
            next({
                userId  : userId,
                url     : 'https://fbcdn-profile-a.akamaihd.net' + res.socket.pair.cleartext._httpMessage.path
            });
        }
    });
};

exports.getToken    = getToken;
exports.getMyId     = getMyId;
exports.steal       = steal;