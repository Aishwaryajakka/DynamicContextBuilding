

app.controller('deviceCtrl', function($scope, $http,$window,$location,commonService){
    console.log('device ctrl loaded');
    $scope.remId = true; 
    $scope.regDev = {};
    var devInfo={};
    $scope.localData={};
    $scope.ds = {"DS_URL":"dweet.io/dweet/for"};
    $scope.common_config={"PACKET_ID":"COMMON_CONFIG_DATA",
                        "GPS_EN_STATUS":"DISABLE",
                        "DEVICEID":devInfo.deviceId,
                        "CUSTOMER_ID":devInfo.userName,
                        "DS_IPADDR":devInfo.ipAddress,
                        "DS_PORTNUMBER":80,
                        "TS_IPADDR":$scope.serverip,
                        "TS_PORTNUMBER":21,
                        "PROTOCOL_SELECTED":'1',
                        "DATA_FORMAT": '0',
                        "DATA_XMIT_FREQ": '0', 
                        "DEVICE_ALIAS_NAME":"ALIAS_NAME", 
                        "DEVICE_CATEGORY":"WIRED_WITH_ETHERNET", 
                        "INSTALLED_LOCATION":"MARATHALLI", 
                        "CONTINEO_USERNAME":"",
                        "CONTINEO_PASSWORD":"",
                        "PLATFORM_SUPPORTED":'0', 
                        "WIFI_NAME":"NAME", 
                        "WIFI_PASSWORD":"PASSOWORD",  
                        "DS_HOSTNAME":"dweet.io", 
                        "DS_PATH":"",
                        "FREEBOARD_THING_NAME":"tangent",
                        "FREEBOARD_KEY":"unknown",
                        "FW_UPDATE_URL": "",
                        "ACTION": ""
                    }
    $scope.SensorData = {
            "VALUE_TEMP_S": "",
            "VALUE_SMK_S": "",
            "VALUE_IR_S": ""
    }
    $scope.register = function(){
        $window.location.href="/register";
    }

    $scope.getDevices = function(){
        if(commonService.localData!=null) 
            $http.defaults.headers.common['Authorization'] = commonService.localData.token;
        else {
            commonService.signout();
        }
        $http.get('/api/getDevices/'+commonService.user.email).success(function(result){
            $scope.devList = result;
            // console.log(result);
        }).error(function(status){
            if(status== 'Unauthorized')
                $scope.signout()
        })
    }

    function get_details(){
        // $scope.localData =  JSON.parse(localStorage.getItem('tandev'))
            var test = new FormData();
                test.name = $scope.name;
                console.log("Take care data :-" + JSON.stringify(test));
            console.log("hello user");
            if(commonService.localData!=null) 
            $http.defaults.headers.common['Authorization'] = commonService.localData.token;
        else {
            commonService.signout();
        }
        //$http.get('/api/download').success(function(result){
        $http.get('/api/getDeviceContextData/').success(function(result){
            
             console.log(result);
             $scope.infoData = result; 
                        
            //$scope.devList = result;
        }).error(function(status){
           if(status== 'Unauthorized')
                $scope.signout()
        })

    }
$scope.myContextData = [];
    function getMyContextData(){

        $http.get('/api/getMyContext/').success(function(result){
            
             console.log(result);
             $scope.myContextData = result;  
            

        //       setInterval( function () {
        //    $scope.fetchSensorData1();
        // //     $scope.fetchSensorData2();
        // //    $scope.fetchSensorData3();
        // }  ,1000);     
        // setInterval( function () {
        // //    $scope.fetchSensorData1();
        //     $scope.fetchSensorData2();
        // //    $scope.fetchSensorData3();
        // }  ,1000);     
        // setInterval( function () {
        // //    $scope.fetchSensorData1();
        // //     $scope.fetchSensorData2();
        //    $scope.fetchSensorData3();
        // }  ,1000);       
            //$scope.devList = result;
        }).error(function(status){
            if(status== 'Unauthorized')
               $scope.signout()
        })
    }

    if($window.location.pathname.indexOf('/wired') != -1){
        getMyContextData();
        get_details();
    }
    $scope.$on('getContextStore',function(event,args){
         getMyContextData();
    });
      $scope.$on('getMyContext',function(event,args){
          
            get_details();
    });
    // getMyContextData();
    // get_details();
    $scope.get_status= function(id){
        console.log("id",id);
        get_details();
         $scope.infoData.map((s)=>{
            if(s._id==id){
             console.log(" $scope.infoData",s);
                $scope.status=s.action.status
            }
            
         })

    }


    $scope.$on('updateDevInfo',function(event,args){
        var DS_URL='';
        if($scope.ds.DS_URL!=undefined && $scope.ds.DS_URL.indexOf('/')!=-1){
            $scope.common_config.DS_PATH = $scope.ds.DS_URL.substring($scope.ds.DS_URL.indexOf('/'));
            $scope.common_config.DS_HOSTNAME = $scope.ds.DS_URL.substring(0,$scope.ds.DS_URL.indexOf('/'));
        }
        $scope.common_config.GPS_EN_STATUS==true ? $scope.common_config.GPS_EN_STATUS=="ENABLE": $scope.common_config.GPS_EN_STATUS=="DISABLE";

        commonService.setConfig($scope.common_config);
    })

    $scope.connect = function(){
        
        console.log($scope.common_config);
        $http.post('/api/fetchsensordata1',$scope.common_config).success(function(result){
            alert(result);
        })

    }

    $scope.signout = function(){
        commonService.signout();
        $window.location.href="/login";
    }
    $scope.checkDev = function(){
        if($scope.devId!==undefined && $scope.devId!="")
        for(var i=0; i<$scope.devList.length; i++){
            if($scope.devId.toLowerCase()==$scope.devList[i].deviceId.toLowerCase() || ($scope.devList[i].aliasName!=null && $scope.devId.toLowerCase()==$scope.devList[i].aliasName.toLowerCase()))
            {
                $scope.removeId = $scope.devList[i].deviceId;
                $scope.remId = false; 

            }
            else {
                $scope.removeId = "";
                $scope.remId = true; 
            }
        }
    }
    $scope.remove = function(){
        var devInfo = '';
        if($scope.removeId==""){
            alert('Device Id not proper to delete')
            return;
        }

        if($scope.removeId==$scope.devId)
            devInfo = $scope.removeId;
        else
            devInfo = $scope.devId + ' ('+$scope.removeId+')';

        var result = confirm("Do you want to delete '"+devInfo+"'");
        if (result) {
            $http.put('/api/remove/'+$scope.removeId).success(function(result){
                if(result=='success') {
                    alert('Removed device Id from your list');
                    // $scope.getDevices();
                    $window.location.href='/';
                }
            })
        }   
    }


    $scope.platformSelect = function(){
        if($scope.common_config.PLATFORM_SUPPORTED!=1){
            $scope.common_config.PROTOCOL_SELECTED='1';
        }else if($scope.common_config.PLATFORM_SUPPORTED==1)
        $scope.common_config.PROTOCOL_SELECTED='2';
    }

    $scope.wiredEndpoint = function(devId) {
        
        commonService.setConfig($scope.common_config);
        // console.log(commonService.getConfig());
        $http.post('/api/set_common_config',$scope.common_config).success(function(result){
            if(result=='success')
                $window.location.href='/wired/'+devId+'/0.0.0.0';
            else 
                alert(result);
        })
        
    }

    // function updateLocalData(){
    //     // $scope.localData =  JSON.parse(localStorage.getItem('tandev'))
        
    //         // $scope.email = $scope.localData.user.name;
    //     // }
            
    //     // else {
    //         $window.location.href="/login";
    //     // }
    // }

    $scope.regDevice = function(){
        
        $scope.regDev.email = commonService.user.email;
        console.log($scope.regDev);
        $http.post('/api/regDevice',$scope.regDev).success(function(result){
            if(result=='success'){
                alert('Registered Successfully');
                $window.location.href='/';
            }else if(result=='exists')
                alert('Already registered with this device id: '+$scope.regDev.devId)
            else if(result=='failed')
                alert('Unable to register. Please check Device Id');
            else
                alert(result);
            
        })
    }
    $scope.getDevices();

    $scope.$on('devInfo',function(event,args){
        $scope.getDevInfo(args.devId);
    })

    $scope.getDevInfo = function(devId){
        $http.get('/api/commonPrams/'+devId).success(function(result){
            devInfo = JSON.parse(result).rec;
            devInfo['serverIP'] = JSON.parse(result).serverIP;
            $scope.common_config.DEVICEID = devInfo.deviceId;
            $scope.common_config.CUSTOMER_ID = devInfo.userName
            $scope.common_config.DS_IPADDR = devInfo.ipAddress
            $scope.common_config.TS_IPADDR = devInfo.serverIP
            $scope.common_config.DEVICE_ALIAS_NAME = devInfo.aliasName;
            if(devInfo.aliasName==null)
                commonService.setAliasName(devId);
            else
                commonService.setAliasName(devInfo.aliasName);
            
        })

    }
    

    $scope.getAnalogInfo = function(ipAddr,devId){
        if(ipAddr=='')
            ipAddr='0.0.0.0';
              getMyContextData();
              get_details();
        $window.location.href='/wired/'+devId+'/'+ipAddr;
        // $window.location.href = '/devparams/'+devId;
    }

    $scope.getContext = function(name){
        $http.get('/api/downloadContext/'+name).success(function(result){
           
             console.log(result);
        //    alert(result);
        }).error(function(status){
            if(status== 'Unauthorized')
                $scope.signout()
        })
    }

  

//*******************************              MY ADDITIONS               ************************ */
   /****************************DOWNLOAD CONTEXT FROM MLAB************************** */



// Check the rules and Send the action to device 
    $scope.usecontext = function (name,info) {

            setTimeout(function(){
                    $scope.fetchSensorData1();
            },1000) 
             setTimeout(function(){
                    $scope.fetchSensorData2();
            },1000) 
             setTimeout(function(){
                    $scope.fetchSensorData3();
            },1000) 
              
       setTimeout(function(){
        var temp_s,ir_s,smoke_s,time_r;
        // *****************************TEMPERATURE SENSOR***********************************
        if(info.rules.temp_s[0] !== 0 || info.rules.temp_s[1] !== 0){
                // $scope.fetchSensorData1();
                
            var lower,upper;
            console.log(info.rules.temp_s[0]);
            console.log(info.rules.temp_s[1]);
              
          if( (info.rules.temp_s[0] !== 0) && (info.rules.temp_s[1] !== 0) ) {
                if( ($scope.SensorData.VALUE_TEMP_S >= info.rules.temp_s[0] ) && ($scope.SensorData.VALUE_TEMP_S <= info.rules.temp_s[1] ))
                             temp_s=1;
                else
                            temp_s=0;         

          }    
                                
          else if ((info.rules.temp_s[0] !== 0) && (info.rules.temp_s[1] === 0)) {                    
             if( ($scope.SensorData.VALUE_TEMP_S >= info.rules.temp_s[0] ))
                        temp_s=1;
                else
                            temp_s=0;      
        }
         else if ((info.rules.temp_s[0] === 0) && (info.rules.temp_s[1] !== 0)) {  
               if( ($scope.SensorData.VALUE_TEMP_S <= info.rules.temp_s[1] ))
                        temp_s=1;
                else
                        temp_s=0;       
           
            }
     }
         else {
             temp_s=1;
              console.log("any");
         }

     //************************************SMOKE SENSOR ***************************

      if(info.rules.smoke_s!== "any"){

                        // $scope.fetchSensorData2();
                        
                     console.log( $scope.SensorData.VALUE_SMK_S);
                    if(info.rules.smoke_s ===  $scope.SensorData.VALUE_SMK_S)
                             smoke_s=1;

                    else
                             smoke_s=0;
    }

    else{
         smoke_s = 1;
          console.log("any");
    }



    //*************************************IR SENSOR***************************************
    if(info.rules.ir_s !== "any"){

                    //    $scope.fetchSensorData3();
                      
                   
                     console.log( $scope.SensorData.VALUE_IR_S);
                    if(info.rules.ir_s ===  $scope.SensorData.VALUE_IR_S)
                             ir_s=1;

                    else
                             ir_s=0;
    }

    else{
             ir_s = 1;
            console.log("any");
    }

   // *********************************************Time *****************************
       var currentTime = new Date()
       var h = currentTime.getHours();
    
    var m = currentTime.getMinutes();
    
       if(h == 24)
            h = 0;
        else if(h > 12)
            h = h - 0;      
         if(h < 10)
            h = "0" + h;
         if(m < 10)   
                m= "0" + m;
        var myClock = h  + ":"  + m;
         console.log(myClock);
        if(info.rules.time_r[0]!=="any" || info.rules.time_r[0]!=="any")
        {
            var lower,upper;
            console.log(info.rules.time_r[0]);
            console.log(info.rules.time_r[1]);
              
          if( (info.rules.time_r[0] != "any") && (info.rules.time_r[1] != "any") ) {

                var curtime1 = info.rules.time_r[0].split(':');
                var curtime2 = info.rules.time_r[1].split(':');
                console.log("hi");
                console.log(parseInt(h));
                console.log(parseInt(curtime1[0]));
                console.log(parseInt(m));
                console.log(parseInt(curtime1[1]));
                console.log(parseInt(curtime2[0]));
                console.log(parseInt(curtime2[1]));
                if(parseInt(curtime1[0])>12)
                   var hour= 24-parseInt(curtime1[0]);
                if(( parseInt(h) >=hour ) && ( parseInt(h)<=parseInt(curtime2[0])))
                            time_r=1;
                else
                           time_r=0;         

          }    
                                
          else if ((info.rules.time_r[0] != "any") && (info.rules.time_r[1] ==  "any")) { 
             var curtime1 = info.rules.time_r[0].split(':');
             if( parseInt(h) >= parseInt(curtime1[0]) && parseInt(m)>=parseInt(curtime1[1]))
                         time_r=1;
                else
                           time_r=0;      
        }
         else if ((info.rules.time_r[0] ==  "any") && (info.rules.time_r[1] != "any")) {  
              var curtime2 = info.rules.time_r[1].split(':');
               if(parseInt(h)<=parseInt(curtime2[0]) && parseInt(m) <=parseInt( curtime2[1] ))
                           time_r=1;
                else
                           time_r=0;     
           
            }  
        }
        else {
                  time_r=1;
               console.log("any"); 
        }
        console.log(temp_s);
           console.log(ir_s);
           console.log(smoke_s);
           console.log(time_r);

       if(temp_s ==1 && ir_s ==1 && smoke_s==1 && time_r==1){
            $scope.common_config.ACTION= info.action;
           
               $http.post('/api/SendActiontoDevice',$scope.common_config).success(function(result){
             console.log(result);
               })
         

       }    
       else
       {
           alert("Cannot use context! ")
       }


    },10000);
           
           

            
       
    }  
    // Temperature sensor


   $scope.fetchSensorData1 = function(){
        var currentTime =new Date();
        console.time("hello");
        // // var start= currentTime.getTime();
        // var start = console.time();
        
        console.log('fetch sensor data 1 called');
        $http.post('/api/fetchsensordata1',$scope.common_config).success(function(result){
            if(result == 'success'){
                    $http.get('/api/getSensorData1',$scope.SensorData).success(function(result){
                        $scope.SensorData.VALUE_TEMP_S = result;
            // alert(result);
        }) 

            }
            console.timeEnd("hello");
        //  var t=end-start;
        //  console.log(t);

        })
 }

// Smoke sensor
     $scope.fetchSensorData2 = function(){
         var currentTime =new Date();
        var start= currentTime.getTime();
        console.log('fetch sensor 2 data called');
        $http.post('/api/fetchsensordata2',$scope.common_config).success(function(result){
             if(result == 'success'){
                    $http.get('/api/getSensorData2',$scope.SensorData).success(function(result){
            // alert(result);
             $scope.SensorData.VALUE_SMK_S = result;
          
         }) 

            }
            var end= currentTime.getTime();
         var t=end-start;
         console.log(t);

        })
 }
//Presence Sensor
    $scope.fetchSensorData3 = function(){

        var currentTime =new Date();
        var start= currentTime.getTime();
        
        console.log('fetch sensor data 3 called');
        $http.post('/api/fetchsensordata3',$scope.common_config).success(function(result){
            if(result == 'success'){
                    $http.get('/api/getSensorData3',$scope.SensorData).success(function(result){
            // alert(result);
             $scope.SensorData.VALUE_IR_S = result;
          }) 

            }
         var end= currentTime.getTime();
         var t=end-start;
         console.log(t);
        })
 }

})// End of controller