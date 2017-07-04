(function() {
'use strict';

angular.module('user')
.config(routeConfig);

/**
 * Configures the routes and views
 */
routeConfig.$inject = ['$stateProvider'];
function routeConfig ($stateProvider) {
  // Routes
  $stateProvider
    .state('user', {
      abstract: true,
      templateUrl: '/public/src/user/user.html'
    })
    .state('user.login', {
      url: '/login',
      templateUrl: '/public/src/user/login/login.html'
    });
    // .state('public.survey', {
    //   url: '/survey',
    //   templateUrl: '/public/src/public/survey/survey.html'
    // });
}
})();
