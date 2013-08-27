MainController = ($scope, $timeout) ->
    $scope.speed = 0
    _notSupported = () ->
        window.alert 'geolocation is not supported'

    _alertPosition = (pos) ->
        $scope.$apply () ->
            $scope.coords = pos.coords
            $scope.speed = Math.ceil(window.parseFloat(pos.coords.speed) * 3.6) if pos.coords.speed
                

    initialize = () ->
        window.navigator.geolocation.watchPosition _alertPosition, _notSupported, {enableHighAccuracy: true, timeout: 100}
        # get the limit with the retreived position
        $scope.limit = 50

    initialize()

module.exports = MainController
