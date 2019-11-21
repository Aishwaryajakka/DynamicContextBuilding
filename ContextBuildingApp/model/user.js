var mongoose = require('mongoose');
var bcrypt   = require('bcrypt-nodejs');

var userSchema = mongoose.Schema({
	name:String,
	email:String,
	password:String,
	status: Boolean,
	otp:Number,
	setDate:Date,
	userId:String,
    role:String, 
	token:String,
    profileImage:String
    
});

userSchema.methods.generateHash = function(password) {
    return bcrypt.hashSync(password, bcrypt.genSaltSync(8), null);
};

// checking if password is valid
userSchema.methods.validPassword = function(password) {
    return bcrypt.compareSync(password, this.password);
};

var User = mongoose.model('user',userSchema);
module.exports = User;