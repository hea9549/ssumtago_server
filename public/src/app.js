(function(){
  'use strict';

  angular.module('Ssumtago',['ui.router'])
  .service('UsersService', UsersService)
  .controller('UsersController', UsersController)
  // .constant('ApiPath', 'http://expirit.co.kr:3000');
  .constant('ApiPath', 'http://localhost:3000');

  UsersController.$inject=['UsersService'];
  function UsersController(UsersService) {
    var users = this;

    users.isLogin = false;
    users.email = "";
    users.password = "";
    users.jwt = "";

    // 이메일 로그인
    users.emailLogin = function() {
      UsersService.emailLogin(users.email, users.password)
      .then(
      // 로그인 성공시
      function successCallback(response){
        console.log(response.data.success);
        users.isLogin = true;
        users.joinType = "email";
        users.jwt = response.data.jwt;

        UsersService.jwtCheck(users.jwt)
        .then(
          // JWT 인증 성공시
          function successCallback(response){
            console.log(response.data);
            users.name = response.data.name;
          },
          function errorCallback(response){
            console.log(response.data.msg);
          }
         )
      },
        // 로그인 실패시
      function errorCallback(response) {
        console.log(response.data.msg);
      });
    };

    // 페이스북로그인
    users.fbLogin = function(userPassword) {
      FB.login(function(response) {
          if (response.authResponse) {
           console.log('Welcome!  Fetching your information.... ');
           FB.api('/me', function(response) {
             console.log('Good to see you, ' + response.name + '.');
             console.log(response);

             var accessToken = FB.getAuthResponse().accessToken;
             console.log(accessToken);
             UsersService.fbLogin(accessToken, response.name)
             .then(
             // 로그인 성공시
             function successCallback(response){
               console.log(response.data.success);
               users.isLogin = true;
               users.joinType = "facebook";
               users.jwt = response.data.jwt;

               UsersService.jwtCheck(users.jwt)
               .then(
                 // JWT 인증 성공시
                 function successCallback(response){
                   console.log(response.data);
                   users.email = response.data.email;
                   users.name = response.data.name;
                 },
                 function errorCallback(response){
                   console.log(response.data.msg);
                 }
                )
             },
               // 로그인 실패시
             function errorCallback(response) {
               console.log(response.data.msg);
             });
           });
          } else {
           console.log('User cancelled login or did not fully authorize.');
          }
      });
    };

    // 로그아웃
    users.logout = function() {
      if (users.joinType == "facebook") {
        FB.logout(function(response) {
          console.log(response);
        });
      }
        users.isLogin = false;
        users.email = "";
        users.password = "";
        users.joinType = "";
        users.name = "";
        users.jwt = "";
    }

  }

  UsersService.$inject = ['$http', 'ApiPath'];
  function UsersService($http, ApiPath) {
    var service = this;

    service.emailLogin = function(userEmail, userPassword) {
      var UserData = {"email": userEmail, "password": userPassword, "joinType":"email"};

      var response = $http({
        method: "POST",
        url: ApiPath + "/sessions",
        data: UserData
      });
      return response;
    };

    service.fbLogin = function(userPassword, userName) {
      var UserData = {"password": userPassword, "name": userName, "joinType":"facebook"};

      var response = $http({
        method: "POST",
        url: ApiPath + "/sessions",
        data: UserData
      });
      return response;
    };



    service.jwtCheck = function(jwt) {
      var response = $http({
        method: "POST",
        url: ApiPath + "/check",
        headers: {
         'jwt': jwt
        }
      });
      return response;
    };

  }


})();
