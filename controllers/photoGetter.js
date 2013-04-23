var events      = require('events');
var photoDb     = require('./photoDatabase');

var getSome = function(quantity, next){
    var returned        = []
    var returnedLength  = 0;

    getAllIds(function(all){
        waiting = new events.EventEmitter();
        waiting.once('ready', function(){
            if(next) { next(returned); }
        });

        for(var i=0; i<quantity; i++){
            selectRandomIdFromList(all, function(id){
                getRecordById(id, function(record){
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

var getRecordById = function(id, next){
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

var selectRandomIdFromList = function(list, next){
    var rando = Math.floor(Math.random() * list.length);
    if(next)    { next(list[rando].id); }
    else        { return list[rando].id }
}

exports.getSome = getSome;