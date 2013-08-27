MainController = ($scope, $timeout) ->
    _notSupported = () ->
        window.alert 'geolocation is not supported'

    _alertPosition = (pos) ->
        console.log pos
        $scope.$apply () ->
            $scope.coords = pos.coords
            $scope.i++
        console.log $scope.coords

    window.navigator.geolocation.watchPosition _alertPosition, _notSupported, {maximumAgeenableHighAccuracy: true, timeout: 1000}

module.exports = MainController
