MainController = require './controllers/main'
MapService = require './services/map'
SpeedService = require './services/speed'

class App
    constructor: () ->
        @module = angular.module 'hack-app', []
        @module.config ['$routeProvider', '$locationProvider', @configureModule]
        @registerServices()
        @registerControllers()

    configureModule: (routeProvider, locationProvider) =>
        locationProvider.html5Mode true

    registerServices: () =>
        @module.factory 'MapService', [MapService]
        @module.factory 'SpeedService', ['$http', SpeedService]

    registerControllers: () =>
        @module.controller 'MainController', ['$scope', '$http', 'MapService', 'SpeedService', MainController]

module.exports = new App()
