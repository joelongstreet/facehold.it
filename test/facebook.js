var assert      = require('assert');
var should      = require('should');
var facebook    = require('../controllers/facebook');

describe('Facebook', function(){

    var facebookToken = '';
    it.skip('should be able to fetch a good token', function(done){
        facebook.getToken(function(token){
            facebookToken = token;
            token.should.be.ok;
            done();
        });
    });

    var myId = 0;
    it.skip('should be able to fetch my user id', function(done){
        facebook.getMyId(facebookToken, function(id){
            id.should.be.ok;
            myId = id;
            done();
        });
    });

    it.skip('should be able to steal my own photo', function(done){
        facebook.steal(myId, function(fbObj){
            fbObj.should.have.property('userId').with.length.above(5);
            fbObj.should.have.property('url').with.length.above(5);
        });
    });
});