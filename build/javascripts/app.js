var App, MainController,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

MainController = require('./controllers/main');

App = (function() {
  function App() {
    this.registerControllers = __bind(this.registerControllers, this);
    this.configureModule = __bind(this.configureModule, this);
    this.module = angular.module('hack-app', []);
    this.module.config(['$routeProvider', '$locationProvider', this.configureModule]);
    this.registerControllers();
  }

  App.prototype.configureModule = function(routeProvider, locationProvider) {
    return locationProvider.html5Mode(true);
  };

  App.prototype.registerControllers = function() {
    return this.module.controller('MainController', ['$scope', '$http', MainController]);
  };

  return App;

})();

module.exports = new App();
