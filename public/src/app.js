(function(){
  'use strict';

  angular.module('UserApp',[])
  .service('UsersService', UsersService)
  .controller('UsersController', UsersController);

  UsersController.$inject=['UsersService'];
  function UsersController(UsersService) {
    var users = this;

    users.email = "";
    users.password = "";
    users.name = "";

    users.addUser = function() {
      var newUser = {"email": users.email, "password": users.password, "name": users.name};
      users.allUsers.push(newUser);
      UsersService.addUser(users.email, users.password, users.name)
      .then(function(response){
        console.log(response);
        users.email = "";
        users.password = "";
        users.name = "";

      });
    }

    users.getUsers = function() {
      UsersService.getUsers()
      .then(function(response){
        users.allUsers = response.data;
        console.log(response);
      });
    };

    users.removeUser = function(UserIndex, $index) {
      users.allUsers.splice($index,1);
      UsersService.removeUser(UserIndex)
      .then(function(response){
        console.log(response);
      });
    };

  };

  UsersService.$inject = ['$http'];
  function UsersService($http){
    var service = this;

    service.getUsers = function() {
      var response = $http({
        method: "GET",
        url: "/users.json"
      });
      return response;
    };

    service.addUser = function(userEmail, userPassword, userName) {
      var UserData = {"user":{"email": userEmail, "password": userPassword, "name": userName}};

      var response = $http({
        method: "POST",
        url: "/users",
        data: UserData
      });
      return response;
    }

    service.removeUser = function(index){
      var response = $http({
        method: "DELETE",
        url: "/users/"+index
      });
      return response;
    };
  };
})();
