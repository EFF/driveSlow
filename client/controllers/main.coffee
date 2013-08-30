MainController = ($scope, $http, MapService, SpeedService) ->
    initialize = () ->
        $scope.speed = 0
        $scope.limit = 0
        $scope.isFirstIteration = true
        $scope.polygons = {}

        window.navigator.geolocation.watchPosition _updateLoop, _geoLocationNotSupported, {enableHighAccuracy: true}
        window.addEventListener 'load', _hideBrowserBar
    
    _hideBrowserBar = () ->
        window.scrollTo 0, 1
        
    _geoLocationNotSupported = () ->
        window.alert 'You need to accept geolocation to use this app'

    _updateLoop = (position) ->
        coords = position.coords
        if $scope.isFirstIteration
            _initMap coords
            $scope.isFirstIteration = false

        _updateCurrentSpeed coords
        MapService.updateMap $scope.map, coords
        SpeedService.isInDangerZone coords.latitude, coords.longitude, _handleIsInDangerZone
        SpeedService.getSpeedLimit coords.latitude, coords.longitude, _handleSpeedLimit

    _initMap = (coords) ->
        $scope.map = MapService.create coords

        google.maps.event.addListener $scope.map, 'bounds_changed', () ->
            northEast =
                latitude: $scope.map.getBounds().getNorthEast().lat()
                longitude: $scope.map.getBounds().getNorthEast().lng()
            southWest =
                latitude: $scope.map.getBounds().getSouthWest().lat()
                longitude: $scope.map.getBounds().getSouthWest().lng()

            SpeedService.getDangerZones northEast, southWest, _handleDangerZones

    _handleSpeedLimit = (error, result) ->
        if error
            console.log 'error', error.error
        else
            $scope.limit = result.data.limit

    _handleDangerZones = (error, result) ->
        if error
            console.log 'error', error.error
        else
            for zone in result
                if not $scope.polygons[zone._id]
                    $scope.polygons[zone._id] = true
                    MapService.createPolygon zone._source.sectorBoundaries.coordinates[0], $scope.map

    _handleIsInDangerZone = (error, result) ->
        if error
            console.log 'error', error.error
        else
            if result.data
                window.alert 'Attention! Vous êtes dans une zone à radar'

    _updateCurrentSpeed = (coords) ->
        $scope.$apply () ->
            $scope.speed = Math.ceil(window.parseFloat(coords.speed) * 3.6) if coords.speed

    initialize()

module.exports = MainController
