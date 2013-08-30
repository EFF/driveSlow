var MainController;

MainController = function($scope, $http) {
  var initialize, isFirstIteration, mapsApi, polygones, _IsInDangerZone, _createMap, _getDangerZones, _getSpeedLimit, _handleGeolocation, _notSupported, _updateMap, _updateUserInfo;
  isFirstIteration = true;
  $scope.speed = 0;
  $scope.limit = 0;
  mapsApi = google.maps;
  polygones = {};
  _notSupported = function() {
    return window.alert('You need to accept geolocation to use this app');
  };
  _handleGeolocation = function(position) {
    if (isFirstIteration) {
      _createMap(position.coords);
      isFirstIteration = false;
    }
    _IsInDangerZone(position.coords);
    _getSpeedLimit(position.coords);
    _updateMap(position);
    return _updateUserInfo(position.coords);
  };
  _createMap = function(coords) {
    var mapOptions;
    mapOptions = {
      center: new mapsApi.LatLng(coords.latitude, coords.longitude),
      replace: true,
      zoom: 15,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    $scope.map = new mapsApi.Map(document.getElementById('map-canvas'), mapOptions);
    return mapsApi.event.addListener($scope.map, 'bounds_changed', function() {
      return _getDangerZones($scope.map.getBounds());
    });
  };
  _getSpeedLimit = function(coords) {
    var options;
    options = {
      method: 'GET',
      url: '/api/speed-limit',
      params: {
        latitude: coords.latitude,
        longitude: coords.longitude
      }
    };
    return $http(options).success(function(result) {
      return $scope.limit = result.data.limit;
    }).error(function(status, error) {
      return console.log('error', status, error);
    });
  };
  _updateMap = function(position) {
    $scope.map.setCenter(new mapsApi.LatLng(position.coords.latitude, position.coords.longitude));
    return $scope.map.setHeading(position.coords.heading);
  };
  _getDangerZones = function(bounds) {
    var options;
    options = {
      method: 'GET',
      url: '/api/photo-radar-zones',
      params: {
        northEast: {
          latitude: bounds.getNorthEast().lat(),
          longitude: bounds.getNorthEast().lng()
        },
        southWest: {
          latitude: bounds.getSouthWest().lat(),
          longitude: bounds.getSouthWest().lng()
        }
      }
    };
    return $http(options).success(function(result) {
      var point, polygonOptions, polygone, shape, zone, _i, _j, _len, _len1, _results;
      _results = [];
      for (_i = 0, _len = result.length; _i < _len; _i++) {
        zone = result[_i];
        if (!polygones[zone._id]) {
          polygones[zone._id] = true;
          polygonOptions = {
            paths: [],
            fillColor: 'red',
            strokeOpacity: 0.5,
            geodesic: true
          };
          shape = zone._source.sectorBoundaries.coordinates[0];
          shape = shape.slice(0, shape.length - 1);
          for (_j = 0, _len1 = shape.length; _j < _len1; _j++) {
            point = shape[_j];
            polygonOptions.paths.push(new mapsApi.LatLng(parseFloat(point[1]), parseFloat(point[0])));
          }
          polygone = new mapsApi.Polygon(polygonOptions);
          _results.push(polygone.setMap($scope.map));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    }).error(function(status, error) {
      return console.log('error');
    });
  };
  _IsInDangerZone = function(coords) {
    var options;
    options = {
      method: 'GET',
      url: '/api/user-in-zone',
      params: {
        latitude: coords.latitude,
        longitude: coords.longitude
      }
    };
    return $http(options).success(function(result) {
      if (result.data) {
        window.alert('Attention! Vous êtes dans une zone à radar');
      }
      return $scope.isInDangerZone = result;
    }).error(function(status, error) {
      return console.log('error', status, error);
    });
  };
  _updateUserInfo = function(coords) {
    return $scope.$apply(function() {
      $scope.coords = coords;
      if (coords.speed) {
        return $scope.speed = Math.ceil(window.parseFloat(coords.speed) * 3.6);
      }
    });
  };
  initialize = function() {
    return window.navigator.geolocation.watchPosition(_handleGeolocation, _notSupported, {
      enableHighAccuracy: true
    });
  };
  return initialize();
};

module.exports = MainController;
