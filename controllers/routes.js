var request     = require('request');
var fs          = require('fs');
var events      = require('events');
var nodealytics = require('nodealytics');
var photoGetter = require('./photoGetter');
var photoMaker  = require('./photoMaker');
var facebook    = require('./facebook');

var fbLocales   = JSON.parse(fs.readFileSync('./data/fb_locales.js','utf-8'))
var analytics   = nodealytics.initialize('UA-3920837-11', 'faceholdit.jit.su');


var home = function(req, res){
    if(req.headers.referrer){
        res.redirect('/pic');
    } else {
        res.redirect('/25');
    }
};

var pic = function(req, res){
    photoGetter.getSome(1, function(users){
        var photo   = users[0].as3Url;
        var url     = 'https://s3.amazonaws.com/facehold/' + as3Url;

        analytics.trackPage('Picture', 'picture');
        res.redirect(url);
    });
};

var addUser = function(req, res){
    facebook.steal(req.params.fbid, function(fbObj){
        photoMaker.save(fbObj, function(){
            res.render('new_user_added', { uid : data.user_id, path : data.as3_path });
        });
    });
};

var addMe = function(req, res){
    facebook.getMyId(function(id){
        facebook.steal(id, function(fbObj){
            photoMaker.save(fbObj, function(){
                res.render('new_user_added', { uid : data.user_id, path : data.as3_path });
            });
        });
    });
};

var getUser = function(req, res){
    var url = 'https://s3.amazonaws.com/facehold/' + req.params.id + '.jpg';
    res.redirect(url);
};

var number = function(req, res){
    if(req.params.number > 100){
        res.render('max')
    } else {
        photo_urls  = []
        index       = 0
        photoGetter.getSome(1, function(users){
            res.render('photos', { photos : users });
        });
    }
};

var hubot = function(req, res){
    photoGetter.getSome(1, function(users){
        var user  = photos[0];
        var fbReq = 'https://graph.facebook.com/' + user.userId;
        request({
            method  : 'GET',
            url     : fbReq,
            timeout : 1500
        }, function(err, resp, body){
            var fbBody  = JSON.parse(body);
            var locale  = '';

            for(var i=0; i<fbLocales.length; i++){
                if(fbLocales[i].fb_code == fbBody.locale){
                    locale = fbLocales[i].nationality;
                }
            }

            res.send({
                id          : fbBody.id,
                name        : fbBody.name,
                gender      : fbBody.gender,
                url         : fbBody.link,
                nationality : locale,
                image       : 'https://s3.amazonaws.com/faceholder/' + user.userId + '.jpg'
            });
        });
    });
};

exports.home        = home;
exports.pic         = pic;
exports.addUser     = addUser;
exports.addMe       = addMe;
exports.getUser     = getUser;
exports.hubot       = hubot;