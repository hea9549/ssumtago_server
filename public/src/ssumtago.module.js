(function() {
"use strict";


angular.module('Ssumtago', ['public'])
.config(config);

config.$inject = ['$urlRouterProvider'];
function config($urlRouterProvider) {

  $urlRouterProvider.otherwise('/');
}

})();
