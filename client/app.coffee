MainController = require './controllers/main'
MapService = require './services/map'

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

    registerControllers: () =>
        @module.controller 'MainController', ['$scope', '$http', 'MapService', MainController]

module.exports = new App()
