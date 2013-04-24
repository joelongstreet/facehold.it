var assert      = require('assert');
var should      = require('should');
var photoGetter = require('../controllers/photoGetter');

describe('Photo Getter', function(){

    var photoObjects = []
    it('should return an array with a length matching the first argument', function(done){
        var argLength = 5;
        photoGetter.getSome(argLength, function(records){
            photoObjects = records;

            records.length.should.equal(argLength);
            done();
        });
    });

    it('should return objects with urls and tags', function(){
        for(var i=0; i<photoObjects.length; i++){
            photoObjects[i].should.have.property('fbUrl');
            photoObjects[i].should.have.property('as3Url');
            photoObjects[i].should.have.property('tags');
        }
    });
});