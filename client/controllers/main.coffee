MainController = ($scope, $http) ->
    isFirstIteration = true
    $scope.speed = 0
    $scope.limit = 0
    mapsApi = google.maps

    _notSupported = () ->
        window.alert 'You need to accept geolocation to use this app'

    _handleGeolocation = (position) ->
        if isFirstIteration
            _createMap position.coords
            isFirstIteration = false
        # else
        #     _getDangerZones $scope.map.getBounds()

        
        # _IsInDangerZone position.coords
        # _getSpeedLimit position.coords
        _updateMap position
        _updateUserInfo position.coords

    _createMap = (coords) ->
        mapOptions =
            center: new mapsApi.LatLng(coords.latitude, coords.longitude)
            replace: true
            zoom: 15
            mapTypeId: google.maps.MapTypeId.ROADMAP
            # draggable: false

        $scope.map = new mapsApi.Map(document.getElementById('map-canvas'), mapOptions)

        polygonOptions =
            map: $scope.map
            paths: [
                [
                    new mapsApi.LatLng(46.836196,-71.226429) #1
                    new mapsApi.LatLng(46.835741,-71.225806) #3
                    new mapsApi.LatLng(46.829855,-71.237587) #4
                    new mapsApi.LatLng(46.830501,-71.238123)
                    new mapsApi.LatLng(46.836196,-71.226429)
                ]
            ]
            fillColor: 'red'
            strokeOpacity: 0.5
            geodesic: true
        new mapsApi.Polygon(polygonOptions)

        mapsApi.event.addListener $scope.map, 'bounds_changed', () ->
            _getDangerZones $scope.map.getBounds()    
        

    _getSpeedLimit = (coords) ->
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

    _updateMap = (position) ->
        $scope.map.setCenter(new mapsApi.LatLng(position.coords.latitude, position.coords.longitude))
        $scope.map.setHeading position.coords.heading
        
    _getDangerZones = (bounds) ->
        console.log bounds
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
            ).error (status, error) ->
            console.log 'error'

        # for each polygons,
        # if the polygon hasn't been drawn already
        # remove last point from polygon and add polygon object in array
        # do

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

    initialize = () ->
        window.navigator.geolocation.watchPosition _handleGeolocation, _notSupported, {enableHighAccuracy: true}
    
    initialize()

module.exports = MainController
