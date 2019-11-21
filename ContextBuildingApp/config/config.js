// config/database.js
module.exports = {
    'secret': 'roof123',
    'dbUri_l' : 'mongodb://127.0.0.1:27017/userdb', 
   

     'dbUri_r' : 'mongodb://aishwaryajakka:jakka08@ds147799.mlab.com:47799/contextstore',

    
    'ipAddress': '0.0.0.0',
     'TCP_PORT':8080,
    'HTTP_PORT':8000,
    'homeAddr':'http://192.168.1.102:8000/',
    'COMMON_CONFIG':{
                        "PACKET_ID":"COMMON_CONFIG_DATA",
                        "GPS_EN_STATUS":"DISABLE",
                        "DEVICEID":"XYZUVWCD123",
                        "CUSTOMER_ID":"",
                        "DS_IPADDR":"",
                        "DS_PORTNUMBER":1025,
                        "TS_IPADDR":'',
                        "TS_PORTNUMBER":21,
                        "PROTOCOL_SELECTED":0,
                        "DATA_FORMAT":0
                    },
    'email':{
        'host':'smtp.gmail.com',
        'port':465,
        'userId':'inforoofcomputing@gmail.com',
        'pwd':'roofp1931.1',
        'regSub':'User Id Registration mail from Roof',
        'forgotPassSub':'Reset Password Request'
    },
    'timeout':900000   //15 mins 1000*60*15

};