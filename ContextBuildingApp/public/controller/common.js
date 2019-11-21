var app = angular.module('deviceInfo',[]);

app.service('commonService',function($http,$window){
    var commonConfig = {};
    var name = {};
    this.mycontextdb = {};
    this.user = {};
    var devAliasName = '';
    this.localData = {};
    this.setConfig = function(val){
        commonConfig = val;
    }
    this.getConfig = function(){
        return commonConfig;
    }

    this.signout = function(){
        localStorage.removeItem('tandev');
        this.user = {};
        $window.location.href='/';
    }

    this.setLocalStorage = function(data){
        localStorage.setItem('tandev',JSON.stringify(data));
    }

    this.getlocalStorage = function(){
        this.localData =  JSON.parse(localStorage.getItem('tandev'));
        if(this.localData!==null)
            this.user = this.localData.user;
    }
    this.getlocalStorage();
    
    this.setAliasName = function(val){
        devAliasName = val;
    }
    this.getAliasName = function(){
        return devAliasName;
    }
})