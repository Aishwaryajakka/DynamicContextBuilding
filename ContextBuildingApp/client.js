const WebSocket = require('net');
var events = require('events');
var emtr = new events.EventEmitter();

argv = require('optimist')
.usage('Usage: client.js -s <server_name> -d <device_id>')
.alias('s', 'server')
.describe('s', 'Hostname/IP of the server.')
.default('s', 'localhost')
.alias('d', 'device')
.describe('Device ID')
.default('dev-foo')
.argv;

var SERVER = argv.s || 'localhost';
var DEVICE_ID = argv.d || 'DEV2134';

const ws = new WebSocket.Socket();
ws.connect(8080,SERVER,function(){
    console.log('connected');
})

// NEW Adiitions
emtr.on('TEMP_S',function(){
    ws.write(JSON.stringify({"VALUE_TEMP_S":"26"}));
})

emtr.on('SMK_S',function(){
    ws.write(JSON.stringify({"VALUE_SMK_S":"NOT_DETECTED"}));
})

emtr.on('IR_S',function(){
    ws.write(JSON.stringify({"VALUE_IR_S":"PRESENT"}));
})
/*************************************************************************** */
emtr.on('COMMON_CONFIG_DATA',function(){

    ws.write(JSON.stringify({"PID":"COMMON_CONFIG_SUCCESS"}));
})

emtr.on('DEV_REG_REQUEST',function(){
    ws.write(JSON.stringify({"PID":"REGDATA_RESPONSE","UM_AVAIL_STAT":"UM_PRESENT"}));
})

emtr.on('DEV_ID_REQUEST',function(){
    ws.write(JSON.stringify({"PID":"DEV_ID_RESP","DEVICE_ID": DEVICE_ID}))
})

ws.on('open', function open() {
  console.log('connected');
//   ws.send(Date.now());
});

ws.on('close', function close() {
  console.log('disconnected');
});


ws.on('data', function incoming(data, flags) {
    console.log(data);
    data = data.toString('utf-8').replace(/}{/g , "} , {")
    var mess = data.toString('utf-8').split(' , ')
    for(var i=0; i<mess.length; i++) {
    
        var pkt = JSON.parse(mess[i]);
        console.log(pkt);
        console.log(pkt.PID);
        switch(pkt.PID) {
        case 'COMMON_CONFIG_DATA':
            emtr.emit('COMMON_CONFIG_DATA');
            break;
        case 'DEV_ID_REQUEST':
            emtr.emit('DEV_ID_REQUEST');
            break;
        case 'UM_CONFIG':
            ws.write(JSON.stringify({"PID":"UM_CONFIG_SUCCESS"}))
            break;
        case 'UM_AIN2_CONFIG' :
            ws.write(JSON.stringify({"PID":"UM_CONFIG_SUCCESS"}))
            break;
        
        case 'UM_AOUT1_CONFIG':
            ws.write(JSON.stringify({"PID":"UM_CONFIG_SUCCESS"}))
            break;
        case 'UM_AOUT2_CONFIG' :
            ws.write(JSON.stringify({"PID":"UM_CONFIG_SUCCESS"}))
            break;
        
        case 'UM_DIN1_CONFIG':
            ws.write(JSON.stringify({"PID":"UM_CONFIG_SUCCESS"}))
            break;
        case 'UM_DIN2_CONFIG' :
            ws.write(JSON.stringify({"PID":"UM_CONFIG_SUCCESS"}))
            break;
        
        case 'UM_DOUT1_CONFIG':
            ws.write(JSON.stringify({"PID":"UM_CONFIG_SUCCESS"}))
            break;
        case 'UM_DOUT2_CONFIG' :
            ws.write(JSON.stringify({"PID":"UM_CONFIG_SUCCESS"}))
            break;
        case 'DEV_REG_REQUEST':
            // console.log(pkt);
            emtr.emit('DEV_REG_REQUEST');
            break;
        case 'TEMP_S' :
            emtr.emit('TEMP_S');
            break;
         case 'SMK_S' :
            emtr.emit('SMK_S');
            break;   
          case 'IR_S' :
            emtr.emit('IR_S');
            break;    

        }
    }
    
});