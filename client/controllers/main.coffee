MainController = ($scope, $http, MapService, SpeedService) ->
    mapsApi = google.maps
    initialize = () ->
        $scope.speed = 0
        $scope.limit = 0
        $scope.isFirstIteration = true
        $scope.polygons = {}

        window.navigator.geolocation.watchPosition _updateLoop, _geoLocationNotSupported, {enableHighAccuracy: true}

    _geoLocationNotSupported = () ->
        window.alert 'You need to accept geolocation to use this app'

    _updateLoop = (position) ->
        if $scope.isFirstIteration
            _initMap position.coords
            $scope.isFirstIteration = false

        _IsInDangerZone position.coords
        _getSpeedLimit position.coords
        _updateMap position
        _updateUserInfo position.coords

    _initMap = (coords) ->
        $scope.map = MapService.create coords

        google.maps.event.addListener $scope.map, 'bounds_changed', () ->
            _getDangerZones $scope.map.getBounds()

    _getSpeedLimit = (coords) ->
        SpeedService.getSpeedLimit coords.latitude, coords.longitude, (error, result) ->
            if error
                console.log 'err', error.error
            else
                $scope.limit = result.data.limit

    _updateMap = (position) ->
        $scope.map.setCenter(new mapsApi.LatLng(position.coords.latitude, position.coords.longitude))
        $scope.map.setHeading position.coords.heading

    _getDangerZones = (bounds) ->
        options =
            method: 'GET'
            url: '/api/photo-radar-zones'
            params:
                northEast:
                    latitude: bounds.getNorthEast().lat()
                    longitude: bounds.getNorthEast().lng()
                southWest:
                    latitude: bounds.getSouthWest().lat()
                    longitude: bounds.getSouthWest().lng()

        $http(options).success((result)->
            for zone in result
                if not $scope.polygons[zone._id]
                    $scope.polygons[zone._id] = true
                    MapService.createPolygon zone._source.sectorBoundaries.coordinates[0], $scope.map
            ).error (status, error) ->
                console.log 'error'

    _IsInDangerZone = (coords) ->
        options =
            method:'GET'
            url: '/api/user-in-zone'
            params:
                latitude: coords.latitude
                longitude: coords.longitude

        $http(options)
            .success((result) ->
                if result.data
                    window.alert 'Attention! Vous êtes dans une zone à radar'
                $scope.isInDangerZone = result
            ).error (status, error) ->
                console.log 'error', status, error

    _updateUserInfo = (coords) ->
        $scope.$apply () ->
            $scope.coords = coords
            $scope.speed = Math.ceil(window.parseFloat(coords.speed) * 3.6) if coords.speed

    initialize()

module.exports = MainController
