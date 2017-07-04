(function() {
"use strict";


angular.module('Ssumtago', ['user'])
.config(config);

config.$inject = ['$urlRouterProvider'];
function config($urlRouterProvider) {

  $urlRouterProvider.otherwise('/login');
}

})();
