var assert      = require('assert');
var should      = require('should');
var photoMaker  = require('../controllers/photoMaker');

describe('Photo Maker', function(){
    it('should allow new photos to be created', function(done){
        this.timeout(15000);
        photoMaker.makeRandomPhoto(function(record){
            record.ok.should.be.true;
            done();
        });
    });
});