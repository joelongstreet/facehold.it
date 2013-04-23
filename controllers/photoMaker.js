var path        = require('path');
var fs          = require('fs');
var request     = require('request');
var knox        = require('knox');
var facebook    = require('./facebook');
var photoDb     = require('./photoDatabase');

var localPhotos = path.dirname(process.mainModule.filename) + '/public/img/';
var as3Bucket   = 'faceholder';
var knoxClient  = knox.createClient({
    key         : process.env.S3_KEY,
    secret      : process.env.S3_SECRET,
    bucket      : as3Bucket
});


var makeOne = function(next){
    facebook.steal(function(fbObj){
        var malePath    = '/static-ak/rsrc.php/v2/yL/r/HsTZSDw4avx.gif';
        var femalePath  = '/static-ak/rsrc.php/v2/yp/r/yDnr5YfbJCH.gif';
        if(fbObj.url == malePath || fbObj.url == femalePath) {
            return false
        } else {
            save(fbObj, function(as3url){
                photoDb.insert({url : as3url}, function(err, body){
                    if(next) { next(body); }
                });
            });
        }
    });
};

var save = function(fbObj, next){
    var fbImageBasePath     = 'https://fbcdn-profile-a.akamaihd.net';
    var localFbPhotoPath    = localPhotos + fbObj.userId + '.jpg';
    var piped               = request(fbImageBasePath + fbObj.url).pipe(fs.createWriteStream(localFbPhotoPath));
    
    piped.on('close', function(){
        var imageName = fbObj.userId + '.jpg';
        knoxClient.putFile(piped.path, imageName, function(err, res){
            fs.unlink(localFbPhotoPath);
            photoDb.insert({
                url     : fbObj.url,
                userId  : fbObj.userId
            }, function(err, body){
                if(!err){
                    if(next) { next(body); }
                }
            });
        });
    });
};