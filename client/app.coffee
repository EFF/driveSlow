MainController = require './controllers/main'

class App
    constructor: () ->
        @module = angular.module 'hack-app', []
        @module.config ['$routeProvider', '$locationProvider', @configureModule]
        @registerControllers()

    configureModule: (routeProvider, locationProvider) =>
        locationProvider.html5Mode true

    registerControllers: () =>
        @module.controller 'MainController', ['$scope', '$http', MainController]

module.exports = new App()
