MainController = ($scope, $timeout) ->
    $scope.i = 0

    _notSupported = () ->
        window.alert 'geolocation is not supported'

    _alertPosition = (pos) ->
        $scope.coords = JSON.stringify pos.coords
        $scope.i++
        $scope.$apply()

    window.navigator.geolocation.watchPosition _alertPosition, _notSupported, {enableHighAccuracy: true, timeout:500}

module.exports = MainController
