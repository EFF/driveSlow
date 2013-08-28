MainController = ($scope, $http) ->
    isFirstIteration = true
    iterator = 0
    $scope.speed = 0
    $scope.limit = 0

    _notSupported = () ->
        window.alert 'You need to accept geolocation to use this app'

    _handleGeolocation = (position) ->
        if isFirstIteration
            _createMap(position.coords)
            isFirstIteration = false
        
        if iterator % 10 is 0
            _getSpeedLimit position.coords
        
        _updateUserInfo position.coords

    _createMap = (coords) ->
        options =
            center: new google.maps.LatLng(coords.latitude, coords.longitude)
            replace: true
            zoom: 17
            mapTypeId: google.maps.MapTypeId.ROADMAP

        map = new google.maps.Map(document.getElementById('map-canvas'), options)

    _getSpeedLimit = (coords) ->
        iterator++
        options =
            method: 'GET'
            url: '/api/speed-limit'
            params:
                latitude: coords.latitude
                longitude: coords.longitude

        $http(options)
            .success((result) ->
                $scope.limit = result.data.limit
            )
            .error (status, error) ->
                console.log 'error', status, error
        
    _updateUserInfo = (coords) ->
        $scope.$apply () ->
            $scope.coords = coords
            $scope.speed = Math.ceil(window.parseFloat(coords.speed) * 3.6) if coords.speed

    initialize = () ->
        window.navigator.geolocation.watchPosition _handleGeolocation, _notSupported, {enableHighAccuracy: true}
    
    initialize()

module.exports = MainController
