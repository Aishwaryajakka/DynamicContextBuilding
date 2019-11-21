var express = require('express');
var router = express.Router();


router.get('/',function(req,res){
    res.render('index');
})

 router.get('/register',function(req,res){
        res.render('register');
})

router.get('/wired/:devId/:ipAddr',function(req,res){
    res.render('wired',{'devId':req.params.devId,'ipAddr':req.params.ipAddr});
})

 router.get('/welcome',function(req, res) {
        res.render('welcome');
    })

router.get('/devparams/:devId',function(req,res){
    res.render('devparams',{'devId':req.params.devId});
})

router.get('/login',function(req,res){
    res.render('login');
})
module.exports = router;