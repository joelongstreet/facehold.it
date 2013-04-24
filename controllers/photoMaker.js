var path        = require('path');
var fs          = require('fs');
var request     = require('request');
var knox        = require('knox');
var facebook    = require('./facebook');
var photoDb     = require('./photoDatabase');

var localPhotos = path.join(__dirname, '../public/img/');
var as3Bucket   = 'facehold';
var knoxClient  = knox.createClient({
    key         : process.env.S3_KEY,
    secret      : process.env.S3_SECRET,
    bucket      : as3Bucket
});


var makeRandomPhoto = function(next){
    var rando = Math.floor(Math.random() * 10000) + 1;
    facebook.steal(rando, function(fbObj){
        if(fbObj.url.indexOf('rsrc.php') != -1) {
            console.log('shitty photo');
            setTimeout(function(){
                makeRandomPhoto(next);
            }, 1000);
        } else {
            doNext(fbObj, next);
        }
    });

    var doNext = function(fbObj, next){
        saveToAS3(fbObj, function(obj){
            saveToCouch(obj, function(record){
                if (next) { next(record) };
            })
        });
    };
};

var saveToAS3 = function(fbObj, next){
    var fbImageBasePath     = 'https://fbcdn-profile-a.akamaihd.net';
    var localFbPhotoPath    = localPhotos + fbObj.userId + '.jpg';
    var piped               = request(fbImageBasePath + fbObj.url).pipe(fs.createWriteStream(localFbPhotoPath));

    piped.on('close', function(){
        var imageName = fbObj.userId + '.jpg';
        knoxClient.putFile(piped.path, imageName, function(err, res){
            fs.unlink(localFbPhotoPath);
            fbObj.as3path = imageName;
            if(res.statusCode == 200) {
                if(next) { next(fbObj); }
            }
        });
    });
};

var saveToCouch = function(fbObj, next){
    photoDb.insert({
        fbUrl   : fbObj.url,
        as3Url  : fbObj.as3path,
        userId  : fbObj.userId,
        tags    : []
    }, function(err, body){
        if(!err){
            if(next) { next(body); }
        }
    });
};

exports.makeRandomPhoto = makeRandomPhoto;