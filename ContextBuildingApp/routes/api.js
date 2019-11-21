var Device = require('../model/device');
var context = require('../model/context');
var config = require('../config/config.js');

/* new addition */
var mongoClient = require('mongodb').MongoClient;
var BSON = require('bson');
var url= 'mongodb://aishwaryajakka:jakka08@ds147799.mlab.com:47799/contextstore';     
var assert = require('assert');
var ObjectId = require('mongodb').ObjectID;
 var d;
//var url = 'mongodb://localhost:27017/test';


/* end */

module.exports = function(app,eventEmitter,passport) {

    app.get('/api/getDevices/:userId', passport.authenticate('jwt', { session: false }), function(req, res) {
            
            Device.find({email:req.params.userId}).lean().exec(function(err, rec) {
                if(err)
                    res.status(500).send({message:err.message});
                else
                    res.json(rec);
            });
        })

    app.get('/api/commonPrams/:devId',passport.authenticate('jwt', { session: false }), function(req, res) {
        Device.find({deviceId:req.params.devId}).lean().exec(function(err, rec) {
            if(err){
                console.log('Device search failed: '+err);
                 res.json('error');
            }
         if(rec.length==1){
            //  rec[0]['serverIP'] =config.ipAddresss;
            res.json(JSON.stringify({'rec':rec[0], 'serverIP':config.ipAddress}));
         }
            
        else
            res.json('failed');
        })
    })

    app.post('/api/regDevice',passport.authenticate('jwt', { session: false }), function(req, res) {
        console.log("show server data:" + JSON.stringify(req.body));
        Device.find({deviceId:req.body.devId}).lean().exec(function(err, rec) {
            if(err){
                console.log('Device search failed: '+err);
                 res.json('error');
            }
            else if(rec.length==1 && rec[0].email==''){
                Device.update({deviceId:req.body.devId}, {
                    $set: {
                        email: req.body.email,
                        aliasName:req.body.aliasName
                    }
                }).lean().exec(function (err, docs) {
                    if (err) {
                        console.log('Device Id record update failed.. ' + err);
                    }
                    else{
                        res.json('success');
                        console.log('updated device username');
                        // console.log(docs);
                    }
                })
            }else if(rec.length==1 && rec[0].email!='' )
                res.json('exists');
            else if(rec.length==0)
                res.json('failed');
        })

    })

    app.get('/api/wiredAnalog/:devId/:devIp',passport.authenticate('jwt', { session: false }), function(req, res) {       
        Device.find({deviceId:req.params.devId}).lean().exec(function(err,rec){
            if(rec.length==1){
                // console.log(rec);
                if(!rec[0].status)
                    res.json('offline');
                else {
                    // eventEmitter.emit('COMMON_CONFIG_DATA',rec[0].ipAddress+':'+rec[0].port,rec[0].deviceId,res)
                    // eventEmitter.emit('COMMON_CONFIG_DATA',rec[0].ipAddress,rec[0].deviceId)
                    res.json('success');
                }
            }else
                res.json('Device is in Offline');
        })
    });

    //Context section api created
    
    app.get('/api/getDeviceContextData/',passport.authenticate('jwt', { session: false }), function(req, res) {  
        //console.log("aaaaaaaaaaaa",req.params.id);     
        var dbConnection = {
         db: null
        }
        // fetching all documents

        mongoClient.connect(url, function (err, db) {
            if (err) {
                console.log(err);
            } 
            else {
                db.collection('contexts').find().toArray(function(e, d) {
                    console.log(d);
                    res.json(d);
                    db.close();
                });
            }
        });
    });
    
    app.get('/api/getMyContext/',passport.authenticate('jwt', { session: false }), function(req, res) {  
           console.log("in my get ");  
         var urlLocal = 'mongodb://127.0.0.1:27017/userdb';   
       
        // fetching all documents

        mongoClient.connect(urlLocal, function (err, db) {
            if (err) {
                console.log(err);
            } 
            else {
                db.collection('mycontextsdb').find().toArray(function(e, d) {
                    console.log(d);
                    res.json(d);
                    db.close();
                });
            }
        });
    });

    app.get('/api/downloadContext/:name',passport.authenticate('jwt', { session: false }), function(req, res) {  

    //var d;
    mongoClient.connect('mongodb://aishwaryajakka:jakka08@ds147799.mlab.com:47799/contextstore', function (err, db) {
    if (err) {
        console.log(err);
    } 
    else {
   db.collection('contexts').find({name : req.params.name}).toArray(function(e, d) {     
          
           //d = JSON.parse(d);
           
           console.log(d);
            db.close();
            console.log("closing the db");
          
            
         mongoClient.connect('mongodb://127.0.0.1:27017/userdb', function(err, db) {
        //   if(db.collection('mycontextsdb').find({name : req.params.name})){
        //           res.json("Context Already Downloaded!");
        //           return;
        //   }
         db.collection('mycontextsdb').insertMany(d, function(err, result) {
       console.log("checking collection");
        assert.equal(err, null);
        console.log("Inserted a document into the mycontexts collection.");
                    // res.json("downloaded");
    
            //   assert.equal(null, err);
            //  // insertDocument(db, function() {
                 db.close();
                   
                });
            }); 
        });
           
    } ;

});  
   
      
    // console.log(req.params.name);     
        res.json(req.params.name);

       
    });

        app.get('/api/download123/',passport.authenticate('jwt', { session: false }), function(req, res) {  
        //console.log("aaaaaaaaaaaa",req.params.id);     
        Context.find().lean().exec(function(err,rec){
            if(!err){
                console.log("amul",rec);
                res.json(rec);
            }else{
                console.log("err",err);
            }
       
         })
    });

    app.put('/api/remove/:devId',passport.authenticate('jwt', { session: false }), function(req, res) {
        Device.find({deviceId:req.params.devId}).lean().exec(function(err,rec){
            if(rec.length==1){
                Device.update({deviceId:req.params.devId}, {
                    $set: {
                        email: '',
                        aliasName:''
                    }
                }).lean().exec(function (err, docs) {
                    if (err) {
                        console.log('Device Id record update failed.. ' + err);
                    }
                    else{
                        res.json('success');
                    }
                })

            }
        })
    })

    app.post('/api/updateCommonConfig',passport.authenticate('jwt', { session: false }), function(req, res) {
        console.log('updateCommonConfig called');
        // console.log(req.body);
        Device.find({deviceId:req.body.DEVICEID}).lean().exec(function(err,rec){
            if(rec.length==1){
                // console.log(rec);
                if(!rec[0].status)
                    res.json('Offline');
                else {
                    var key = rec[0].ipAddress+':'+rec[0].port;
                    // console.log(req.body.data);
                    eventEmitter.emit('UPDATE_COMMON_DATA',key,req.body);
                    eventEmitter.emit('COMMON_CONFIG_DATA',key,rec[0].deviceId,res)
                    
                }
            }
        })

    })

    app.post('/api/wiredpoints',passport.authenticate('jwt', { session: false }), function(req, res) {
        // console.log(req)
        Device.find({deviceId:req.body.devInfo.devId}).lean().exec(function(err,rec){
            if(rec.length==1){
                // console.log(rec);
                if(!rec[0].status)
                    res.json('offline');
                else {
                    var key = rec[0].ipAddress+':'+rec[0].port;
                    eventEmitter.emit('UPDATE_COMMON_DATA',key,req.body.common);
                    eventEmitter.emit('COMMON_CONFIG_DATA',key,rec[0].deviceId,res,req.body.data)
                    
                }
            }
        })
    })

                /************************************API's for USE CONTEXT BUTTON ******************************************** */

                


                // REST API To action  packet to TCP
                app.post('/api/SendActiontoDevice',passport.authenticate('jwt', { session: false }), function(req, res) {
                      console.log('Send action to device called');
        // console.log(req.body);
             Device.find({deviceId:req.body.DEVICEID}).lean().exec(function(err,rec){
            if(rec.length==1){
                // console.log(rec);
                if(!rec[0].status)
                    res.json('Offline');
                else {
                    var key = rec[0].ipAddress+':'+rec[0].port;
                    // console.log(req.body.data);
                    
                     eventEmitter.emit('SEND_ACTION',key,rec[0].deviceId,res,req.body.ACTION)
                    
                    // res.json('hello success');
                    
                }
            }
                      
             })
                })


                
/********************************************API's for Device Dashboard********************************************** */

                /*******TEMPERATURE SENSOR****** */

  /**************** Request to client*************************/
        app.post('/api/fetchsensordata1',passport.authenticate('jwt', { session: false }), function(req, res) {
        console.log('fetchsensordata1 called');
        // console.log(req.body);
        Device.find({deviceId:req.body.DEVICEID}).lean().exec(function(err,rec){
            if(rec.length==1){
                // console.log(rec);
                if(!rec[0].status)
                    res.json('Offline');
                else {
                    var key = rec[0].ipAddress+':'+rec[0].port;
                    // console.log(req.body.data);
                    
                    eventEmitter.emit('TEMP_S',key,rec[0].deviceId,res);
                    
                    // res.json('hello success');
                    
                }
            }
        })

    })
                                         
                // Send value to client
   app.get('/api/getSensorData1',passport.authenticate('jwt', { session: false }), function(req, res) {
                        console.log("Temperature Sensor Recieved");
                        eventEmitter.emit('VALUE_TEMP_S',res);
 })  
   /*********SMOKE SENSOR**************** */

    app.post('/api/fetchsensordata2',passport.authenticate('jwt', { session: false }), function(req, res) {
        console.log('fetchsensordata2 called');
        // console.log(req.body);
        Device.find({deviceId:req.body.DEVICEID}).lean().exec(function(err,rec){
            if(rec.length==1){
                // console.log(rec);
                if(!rec[0].status)
                    res.json('Offline');
                else {
                    var key = rec[0].ipAddress+':'+rec[0].port;
                    // console.log(req.body.data);
                    
                    eventEmitter.emit('SMK_S',key,rec[0].deviceId,res)
                    // res.json('hello success');
                    
                }
            }
        })

    })
    // Recieve  from client
  app.get('/api/getSensorData2',passport.authenticate('jwt', { session: false }), function(req, res) {
                        console.log("smoke Sensor Recieved");
                             eventEmitter.emit('VALUE_SMK_S',res);
                        })
                /****************PRESENCE SENSOR*******************/   

                // Send packet to device
  app.post('/api/fetchsensordata3',passport.authenticate('jwt', { session: false }), function(req, res) {
        console.log('fetchsensordata3 called');
        // console.log(req.body);
        Device.find({deviceId:req.body.DEVICEID}).lean().exec(function(err,rec){
            if(rec.length==1){
                // console.log(rec);
                if(!rec[0].status)
                    res.json('Offline');
                else {
                    var key = rec[0].ipAddress+':'+rec[0].port;
                    // console.log(req.body.data);
                    
                    eventEmitter.emit('IR_S',key,rec[0].deviceId,res)
                    // res.json('hello success');
                    
                }
            }
        })

    })
                // Send recieve from client
                app.get('/api/getSensorData3',passport.authenticate('jwt', { session: false }), function(req, res) {
                        console.log("Presence Sensor Recieved");
                         eventEmitter.emit('VALUE_IR_S',res);                      
                 })

                /*****************************END****************************************** */


}