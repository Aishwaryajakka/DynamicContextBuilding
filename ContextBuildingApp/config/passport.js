// load all the things we need

var LocalStrategy   = require('passport-local').Strategy;
var JwtStrategy = require('passport-jwt').Strategy;  
var ExtractJwt = require('passport-jwt').ExtractJwt; 
var crypto = require('crypto');
var nodemailer = require("nodemailer");
var smtpTransport = require("nodemailer-smtp-transport")

// process.chdir('../')

var User = require(process.cwd()+'/model/user');

var config = require('./config.js');  

// load the auth variables
// var configAuth = require('./auth'); // use this one for testing

module.exports = function(passport) {

    var opts = {};
    opts.jwtFromRequest = ExtractJwt.fromAuthHeader();
    opts.secretOrKey = config.secret;

    var transporter = nodemailer.createTransport(smtpTransport({
        host : config.email.host,
        secure : true,
        port: config.email.port, 
        auth : {
            user : config.email.userId,  
            pass : config.email.pwd
        },
        tls: {rejectUnauthorized: false},
    }));

    // =========================================================================
    // passport session setup ==================================================
    // =========================================================================
    // required for persistent login sessions
    // passport needs ability to serialize and unserialize users out of session

    // used to serialize the user for the session
    passport.serializeUser(function(user, done) {
        done(null, user.id);
    });

    // // used to deserialize the user
    passport.deserializeUser(function(id, done) {
        User.findById(id).lean().exec(function(err, user) {
            done(err, user);
        });
    });

    passport.use(new JwtStrategy(opts, function(jwt_payload, done) {
        User.findOne({id: jwt_payload.id}, function(err, user) {
        if (err) {
            return done(err, false);
        }
        if (user) {
            done(null, user);
        } else {
            done(null, false);
        }
        });
    }));

    function registerEmail(user){
        var url =config.homeAddr+'regactivate/'+user.token+'/'+user.email;
        // var randomVal = Math.floor((Math.random() * 1000000) + 1);
        transporter.sendMail({
            from: config.email.userId, //"inforoofcomputing@gmail.com", // sender address
            to: user.email, // comma separated list of receivers
            subject: config.email.regSub, // Subject line
            html: "Dear "+ user.name+",<br/> Thanks for registering with Roof.<br/> To activate the account, please use this confirmation code <h3>"+ user.otp + "</h3> <br/>Regards, <br/>Roof Team<br/>",
        }, function(error, response){
            if(error){
                console.log(error);
            }else{
                console.log("Message sent: " + response.message);
            }
        });
    }

    passport.use('local-signup', new LocalStrategy({
            // by default, local strategy uses username and password, we will override with email
            usernameField : 'email',
            passwordField : 'password',
            nameField : 'name',
            passReqToCallback : true // allows us to pass back the entire request to the callback
        },
        function(req, email, password, done) {

            // find a user whose email is the same as the forms email
            // we are checking to see if the user trying to login already exists
            User.findOne({ 'email' :  email }).lean().exec( function(err, user) {
                // if there are any errors, return the error
                if (err)
                    return done(err);

                // check to see if theres already a user with that email
                if (user) {
                    return done(null, false);
                } else {
                    var newUser = new User();
                     var randomVal = Math.floor((Math.random() * 1000000) + 1);
                    // set the user's local credentials
                    newUser.email    = email;
                    newUser.password = newUser.generateHash(password); // use the generateHash function in our user model
                    newUser.name = req.body.name;
                    newUser.status='false';
                    newUser.otp = randomVal,
                    // newUser.token = crypto.randomBytes(64).toString('hex');
                    newUser.role=0;
                    newUser.profileImage='/fonts/male.png';
                    // save the user
                    newUser.save(function(err) {
                        if (err)
                            throw err;
                        else {
                            registerEmail(newUser);
                            setTimeout(checkUser,config.timeout,newUser);
                            return done(null, newUser);
                        }
                    });
                }

            });

        }));

    // =========================================================================
    // LOCAL LOGIN =============================================================
    // =========================================================================

    function checkUser(user){
        console.log('check User called');
        console.log(user);
        User.findOne({ 'email' :  user.email }, function(err, usr) {
            if(err)
                console.log('Check user fetch record failed : '+err);
            else {
                console.log('Checking user status');
                if(usr.status==false){
                    console.log('removing the user');
                    User.remove({'email': usr.email, 'status':false},function(err,doc){
                        if(err)
                            console.log('Remove User id failed during cleanup')
                        else{
                            console.log('Remove status for user:'+ usr.email+': '+doc);
                        }
                    })
                }
            }
        });
    }
    passport.use('local-login', new LocalStrategy({
            // by default, local strategy uses username and password, we will override with email
            usernameField : 'email',
            passwordField : 'password',
            passReqToCallback : true // allows us to pass back the entire request to the callback
        },
        function(req, email, password, done) { // callback with email and password from our form

            // find a user whose email is the same as the forms email

            User.findOne({ 'email' :  email }, function(err, user) {
                if (err)
                    return done(err);

                // if no user is found, return the message
                if (!user)
                    return done(null, false ); // req.flash is the way to set flashdata using connect-flash

                // if the user is found but the password is wrong
                if (!user.validPassword(password))
                    return done(null, false); // create the loginMessage and save it to session as flashdata

                // return successful user
                return done(null, user);
            });

        }));



};
