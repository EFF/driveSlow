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
        
        # _getSpeedCameraAreas $scope.map.getBounds()
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
        
    _getSpeedCameraAreas = (bounds) ->
        # options =
        #     method: 'GET'
        #     url: '/'
        # $http options

        # for each polygons,
        # if the polygon hasn't been drawn already
        # remove last point from polygon and add polygon object in array
        # do
        polygonOptions =
            map: $scope.map
            paths: [
                [
                    new mapsApi.LatLng(46.89227,-71.212867) #1
                    new mapsApi.LatLng(46.89727  ,  -71.205593) #3
                    new mapsApi.LatLng(46.891551 ,  -71.212116) #4
                    # remove last point from polygon, and for each point in polygon, create new LatLng
                ]
            ]
            fillColor: 'red'
            strokeOpacity: 0.5
            geodesic: true
        new mapsApi.Polygon(polygonOptions)

    _IsInDangerZone = (coords) ->
        # TODO: get the shit with $http

    _updateUserInfo = (coords) ->
        $scope.$apply () ->
            $scope.coords = coords
            $scope.speed = Math.ceil(window.parseFloat(coords.speed) * 3.6) if coords.speed

    initialize = () ->
        window.navigator.geolocation.watchPosition _handleGeolocation, _notSupported, {enableHighAccuracy: true}
    
    initialize()

module.exports = MainController
