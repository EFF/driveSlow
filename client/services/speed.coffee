Speed = ($http) ->
    getSpeedLimit = (latitude, longitude, callback) ->
        params =
            latitude: latitude
            longitude: longitude

        _get '/api/speed-limit', params, callback

    _get = (url, params, callback) ->
        options =
            method: 'GET'
            url: url
            params: params
        
        $http(options)
            .success(_onSuccess.bind(@, callback))
            .error(_onError.bind(@, callback))
    
    _onSuccess = (callback, result) ->
        callback null, result

    _onError = (callback, error, status) ->
        callback {error: error, status: status}

    service = 
        getSpeedLimit : getSpeedLimit
    return service

module.exports = Speed
