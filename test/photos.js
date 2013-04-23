var assert      = require('assert');
var should      = require('should');
var photoUtils  = require('../controllers/PhotoUtils');

describe('Photo Utils', function(){

    it('should return an array with a length matching the first argument', function(done){
        var argLength = 5;
        photoUtils.getSome(argLength, function(photos){
            photos.length.should.equal(argLength);
            done();
        });
    });


});