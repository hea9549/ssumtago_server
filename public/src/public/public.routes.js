(function() {
'use strict';

angular.module('public')
.config(routeConfig);

/**
 * Configures the routes and views
 */
routeConfig.$inject = ['$stateProvider'];
function routeConfig ($stateProvider) {
  // Routes
  $stateProvider
    .state('public', {
      abstract: true,
      templateUrl: '/public/src/public/public.html'
    })
    .state('public.home', {
      url: '/',
      templateUrl: '/public/src/public/home/home.html'
    })
    .state('public.survey', {
      url: '/survey',
      templateUrl: '/public/src/public/survey/survey.html'
    });
}
})();
