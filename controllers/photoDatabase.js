var nano        = require('nano')('http://joelongstreet.iriscouch.com');
module.exports  = nano.db.use('faceholder_photos');