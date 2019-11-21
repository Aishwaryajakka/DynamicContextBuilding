var jwt = require('jsonwebtoken');
var User = require(process.cwd()+'/model/user');
var config = require('../config/config.js');
var nodemailer = require("nodemailer");
var smtpTransport = require("nodemailer-smtp-transport");
var crypto = require('crypto');

module.exports = function(app, passport) {

    var transporter = nodemailer.createTransport(smtpTransport({
        host : config.email.host,
        secure : true,
        port: config.email.port, 
        auth : {
            user : config.email.userId,  
            pass : config.email.pwd
        },
        tls: {rejectUnauthorized: false}
    }));
    
    // =====================================
    // LOGIN ===============================
    // =====================================
    // show the login form
    app.get('/login', function(req, res) {

        res.end();
    });

    function forgotpassmail(user){
         var url =config.homeAddr+'reqresetpass/'+user.token+'/'+user.email;
        transporter.sendMail({
            from: config.email.userId, 
            to: user.email, 
            subject: config.email.forgotPassSub, 
            html: "Dear "+ user.name+",<br/> Reset password request registered.<br/> To reset the password, please use the below code <h3 style='color:red;'>"+ user.otp + "</h3> <br/> Regards, <br/>Tangent Team<br/>",
        }, function(error, response){
            if(error){
                console.log(error);
            }else{
                console.log("Message sent to reset password for User: "+user.email);
            }
        });
    }

    app.get('/resentOTP/:email',function(req,res){
        console.log('Calling for resend confirmation code');
        User.findOne({'email':req.params.email},function(err,user){
            if(err)
            console.log('Error about resentOTP '+err);
            else if(user){
                transporter.sendMail({
                    from: config.email.userId, 
                    to: user.email, 
                    subject: config.email.regSub, 
                    html: "Dear "+ user.name+",<br/> Thanks for registering with ROOF.<br/> To activate the account, please use this confirmation code <h3 style='color:red;'>"+ user.otp + "</h3> <br/>Regards, <br/>ROOF team<br/>",
                }, function(error, response){
                    if(error){
                        console.log(error);
                    }else{
                        console.log("Message resent to : "+req.params.email );
                        res.json('success');
                    }
                });
            }else
            res.json('User not found. Please register');
        })

    })

    app.post('/confirmuser',function(req,res){
        User.findOne({'email':req.body.email},function(err,user){
            if(err)
                console.log(err)
            else if(user){
                if(user.otp==req.body.otp){
                    User.update({email:user.email},{
                        $set:{
                            status:'true',
                            otp:0,
                        }
                    }).lean().exec(function(err,docs){
                        if(err)
                            console.log('Update record failed:: '+err);
                        else   
                            res.json('success');
                    })
                }else
                res.json('Invalid OTP');
            }else
                res.json('Invalid User');
        })

    })

    app.get('/forgotpass/:email',function(req,res){
        User.findOne({'email':req.params.email},function(err,user){
            if(err)
                console.log(err) 
            else if(user){
                var randomVal = Math.floor((Math.random() * 1000000) + 1);
                User.update({email:user.email}, {
                    $set: {
                        otp : randomVal
                    }
                }).lean().exec(function (err, docs) {
                    // forgotpassmail(docs);
                    User.findOne({'email':req.params.email},function(err,usr){
                        forgotpassmail(usr);
                        res.send({ success: true, message: 'Reset Password request sent to your email id.' });
                    })
                    
                })
                
            }
            else
                res.send({ success: false, message: 'Mail id not registered. ' });
        })
    })

    // =====================================
    // SIGNUP ==============================
    // =====================================
    // show the signup form   


    // process the signup form
    app.post('/signup', passport.authenticate('local-signup', {
        successRedirect : '/success', 
        failureRedirect : '/failure' 
    }));

    app.post('/resetpass',function(req,res){
        User.findOne({'email':req.body.email},function(err,user){
            if(err)
                console.log(err)
            else if(user){
                if(req.body.otp==user.otp) {
                    User.update({email:user.email}, {
                        $set: {
                            otp: 0,
                            password:new User().generateHash(req.body.password)
                        }
                    }).lean().exec(function (err, docs) {
                        res.json({ success: true, message: 'Updated successfully.' });
                    })
                }else
                res.json({success:false, message:'Invalid OTP'});
            }else {
                res.json({ success: true, message: 'Invalid Request' });
            }
                
        })
    })
    
    app.get('/regactivate/:token/:email',function(req,res){
        User.findOne({'token':req.params.token, 'email':req.params.email},function(err,user){
            if(err)
                console.log(err) 
            else if(user){
                User.update({email:user.email}, {
                    $set: {
                        token: '',
                        status:'true'
                    }
                }).lean().exec(function (err, docs) {
                    res.send('Activation succeeded. Please Login');
                })
            }else {
                User.findOne({'email':req.params.email},function(err,user){
                    if(err)
                        console.log(err)
                    if(user)
                        res.send('Already registered and activated');
                    else
                        res.send('Invalid access');
                });
            }
        })
    })

    app.post('/signin', function(req, res) {  
        User.findOne({
            email: req.body.email
        }, function(err, user) {
            if (err) throw err;

            if (!user) {
            res.json({ success: false, message: 'Authentication failed. User not found.' });
        } else {
            if(!user.status){
                res.json({ success: false, message: 'Registered User not activated. Please check your email.' });
            }
            // Check if password matches
            else if (user.validPassword(req.body.password)) {
                // if (isMatch && !err) {
                // Create token if the password matched and no error was thrown
                var token = jwt.sign(user, config.secret, {
                    expiresIn: 10080 // in seconds
                });
                res.json({ success: true, token: 'JWT ' + token, user:{name:user.name, email:user.email, role:user.role} });
                } else {
                res.send({ success: false, message: 'Authentication failed. Passwords did not match.' });
                }
            // };
            }
        });
    });

    //Common Method -----------------------------------------

    app.get('/logout', function(req, res) {
        req.logout();
        req.session.destroy();
        res.send('success');
    });

    app.get('/success', function(req, res) {
            console.log('success request: ');
            console.log(req.user);
            res.json("success");
            
        }
    );

    app.get('/failure', function(req, res) {
            console.log('failure request: ');
            res.send("EXIST");
        }
    );


    app.get('/loginStatus',
        isLoggedIn,
        function(req, res) {
            console.log(req.user);
            if(req.user)
                res.send({role:req.user.role, id:req.user._id});
            else
                res.redirect('/');
        }
    );
};

// route middleware to ensure user is logged in
function isLoggedIn(req, res, next) {
    if (req.isAuthenticated())
        return next();

    res.redirect('/');
}
