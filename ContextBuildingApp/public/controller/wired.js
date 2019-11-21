// var app = angular.module('deviceInfo',[]);


app.controller('wiredCtrl', function($scope, $http,$window,$location,commonService){
    $scope.userName = '';

    // console.log($rootScope.devId);
    // console.log($location.path());
    $scope.signout = function(){
        localStorage.removeItem('tandev');
        $window.location.href="/";
    }
    
    $scope.getDevices = function(){
        // $scope.localData =  JSON.parse(localStorage.getItem('tandev'))
        if(commonService.localData!=null){
            $http.defaults.headers.common['Authorization'] = commonService.localData.token;
            // $scope.userName = $scope.localData.user.name;
            $http.get('/api/getDevices/'+commonService.user.email).success(function(result){
                $scope.devList = result;
                $scope.$root.$broadcast("devInfo", {devId: $scope.devId });
            
            }).error(function(status){
            if(status== 'Unauthorized')
                commonService.signout()
            })
        }else 
        commonService.signout();
    }
    $scope.getDevices();

 //Context section client 
    // $scope.download = function(){
    //         $scope.name = '';
    //     console.log("hello vikash:-" + $scope.name);
    // }
    

    $scope.register = function(){
        $window.location.href = '/register';
    }
    //console.log(commonService.getConfig());

    // $scope.remove = function(){
    //     // console.log(commonService.getAliasName())
    //     var result = confirm("Do you want to delete '"+commonService.getAliasName()+"'");
    //     if (result) {
    //         $http.put('/api/remove/'+$scope.devId+'/'+$scope.ipAddr).success(function(result){
    //             if(result=='success') {
    //                 alert('Removed device Id from your list');
    //                 // $scope.getDevices();
    //                 $window.location.href='/';
    //             }
    //         })
    //     }        
        
    // }


    $scope.signout = function(){
        localStorage.removeItem('tandev');
        $window.location.href='/login';
    }

    

    $scope.connect = function(){
        $scope.$root.$broadcast("updateDevInfo");

        console.log(commonService.getConfig());
        
        $scope.analog["common"] = commonService.getConfig();
        
        if($scope.analog["common"].DEVICE_ALIAS_NAME==null)
                $scope.analog["common"].DEVICE_ALIAS_NAME = "0";

        $http.post('/api/updateCommonConfig',$scope.analog.common).success(function(result){
            if(result=='success')
                $scope.connection=true;
            alert(result);
        })

    }

    $scope.send = function(){
        $scope.$root.$broadcast("updateDevInfo");
        changeStatus();
        console.log(commonService.getConfig());
        
        $scope.analog["common"] = commonService.getConfig();
        
        if($scope.analog["common"].DEVICE_ALIAS_NAME==null)
                $scope.analog["common"].DEVICE_ALIAS_NAME = "0";

        devInfo["devId"] = $scope.devId;
        devInfo ["ipAddr"] = $scope.ipAddr;

        $scope.analog["devInfo"] = devInfo;
        $scope.analog["data"] = $scope.data;
        $scope.alalog["common"] =  commonService.getConfig();
        $http.post('/api/wiredpoints',$scope.analog).success(function(result){
            
            if(result=='success'){
                alert('Updated Successfully');
                $window.location.href='/';
            }else
                alert(result);
        })

        console.log($scope.analog);
    }

    $scope.changeVal = function(sec,sub){
        if($scope.wiredsection=='common' && sec=='wired')
            $scope.$root.$broadcast("updateDevInfo");

            switch($scope.wiredsection){

                case  'common':

                break;
                case  'fw':
                      $scope.$root.$broadcast("getContextStore");
                break;
                case  'wire':
                    $scope.$root.$broadcast("getMyContext");
                break;

            }
        $scope.wiredsection = sec
        $scope.wiredpoints = sub;
    }

    $scope.getAnalogInfo = function(ipAddr,devId){
        if(ipAddr=='')
            ipAddr='0.0.0.0';
        $http.get('/api/wiredAnalog/'+devId+'/'+ipAddr).success(function(result){
            if(result=='success'){
                $window.location.href='/wired/'+devId+'/'+ipAddr;
            }else
                alert(result);
        })
    }


});