var events  = require('events');
var nano    = require('nano')('http://joelongstreet.iriscouch.com');
var photoDb = nano.db.use('faceholder_photos');


var getSome = function(quantity, next){
    var returned        = []
    var returnedLength  = 0;

    getAllIds(function(all){
        waiting = new events.EventEmitter();
        waiting.once('ready', function(){
            if(next) { next(returned); }
        });

        for(var i=0; i<quantity; i++){
            selectRandomId(all, function(id){
                getById(id, function(record){
                    returned.push(record);
                    returnedLength++;

                    if(returnedLength == quantity){
                        waiting.emit('ready');
                    };
                });
            });
        };
    });
};

var getById = function(id, next){
    photoDb.get(id, function(err, body){
        if(err)         { console.log(err)  }
        else if(next)   { next(body);       }
    });
};

var getAllIds = function(next){
    photoDb.list(function(err, body){
        if(next) { next(body.rows); }
    });
};

var selectRandomId = function(list, next){
    var rando = Math.floor(Math.random() * list.length);
    if(next)    { next(list[rando].id); }
    else        { return list[rando].id }
}

exports.getSome = getSome;