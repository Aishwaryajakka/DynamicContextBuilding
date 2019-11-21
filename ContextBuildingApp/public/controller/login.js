// var app = angular.module('deviceInfo',[]);

app.controller('loginCtrl', function($scope, $http,$window,$location,commonService){


$scope.login = {};
$scope.reg={};
$scope.forgot={};
$scope.reset = {};
$scope.location = 'login';

$scope.changeLocation = function(val){
    $scope.location = val;
}

$scope.loginForm = function(){
    $http.post('/signin',$scope.login).success(function(data){
        // console.log(data);
        if(data.success){
            commonService.setLocalStorage(data);
            
            $window.location.href="/welcome";
            
        }
        else 
            alert(data.message);
    })
}

var isLoggedIn = function(){
    if(localStorage.getItem('tandev')!=undefined)
        $window.location.href='/welcome'; 
}

isLoggedIn();
 $scope.confirm = {};

$scope.regUser = function(){
    // console.log($scope.reg);
    var formData = {
        name:$scope.reg.name,
        email: $scope.reg.email,
        password:$scope.reg.password
    }
    if($scope.reg.password==$scope.reg.confirm){
        $http.post('/signup',formData).success(function(data){
            if(data == 'success') {
                alert('Registered Successfully and confirmation code delivered to email.');
                $scope.confirm.email = $scope.reg.email;
                $scope.location = 'regconfirm';
            }else if(data=='EXIST')
                    alert('User already registered...');
            else 
                alert(data);
        })
    }else
    alert('Password not matching');
}

$scope.resendOTP = function(email) {
    // alert('sending email to '+email);
    if(email!=undefined) {
        $http.get('/resentOTP/'+email).success(function(data){
            if(data == 'success')
                alert('Sent email to '+email);
            else
                alert(data);
        })
    }else
     alert('No Email found and invalid request');
}

$scope.confirmUser = function(){
    $http.post('/confirmuser',$scope.confirm).success(function(data){
        if(data=='success'){
            alert('Registered User activated');
            $scope.confirm={};
            $scope.location = 'login';
        }
        else 
            alert(data);
            
    })
}

$scope.resetPass = function(){
    if($scope.reset.email ==undefined)
    {
        alert('Invalid email id')
        return;
    }
    if($scope.reset.password!==$scope.reset.confirm){
        alert('Password not matching');
        return;
    }
    var formData = {
        email: $scope.reset.email,
        password:$scope.reset.password,
        otp:$scope.reset.otp
    }

    if($scope.reset.password==$scope.reset.confirm){
        $http.post('/resetpass',formData).success(function(data){
            if(data.success) {
                alert('Updated Successfully');
                $window.location.href="/login";
            }
            else 
                alert(data.message);
        })
    }
}

$scope.forgotpass = function(){

    $http.get('/forgotpass/'+$scope.forgot.email).success(function(res){
        if(res.success ){
            alert(res.message+'\n. Please use the same for reset password');
            $scope.reset.email = $scope.forgot.email;
            $scope.changeLocation('resetpass');
        }else
            alert(res.message);
        $scope.forgot={};
    })
}

})