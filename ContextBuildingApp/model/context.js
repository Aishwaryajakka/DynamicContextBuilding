var mongoose = require('mongoose');

var contextSchema = mongoose.Schema({
    id : String,
	name:String,
    rules:{
        temp_s : Array,
        ir_s : String,
        smoke_s: String,
        time : Array
    },
    action: {
        alarm : String,
        light : String,
        fan : String,
        lock: String
    }
});

var context = mongoose.model('mycontextdb',contextSchema);

module.exports = context;