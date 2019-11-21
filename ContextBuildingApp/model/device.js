var mongoose = require('mongoose');

var deviceSchema = mongoose.Schema({
	deviceId:String,
	ipAddress:String,
	port:String,
	status: Boolean,
	aliasName:String,
	email:String,
	regDate:Date
});

var device = mongoose.model('device',deviceSchema);

module.exports = device;