var nano        = require('nano')('http://joelongstreet.iriscouch.com');
module.exports  = nano.db.use('facehold');