async = require 'async'
request = require 'request'
stylus = require 'stylus'
express = require 'express'
path = require 'path'
http = require 'http'

publicDirectory = path.join __dirname, '../build'
stylusSource = path.join __dirname, '../client/stylesheets/'
stylusDestination = path.join __dirname, '../build/stylesheets/'

app = express()

app.configure () ->
    app.use express.static(publicDirectory)

    app.locals.apiKey = process.env.MAPS_API_KEY
    app.set 'views', __dirname + '/views'
    app.set 'view engine', 'jade'

    app.use express.logger('dev')

    app.use stylus.middleware({src : stylusSource, dest: stylusDestination})
    app.use express.static(publicDirectory)

    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use app.router

app.get '/', (req, res) ->
    res.render 'index'

app.get '/api/photo-radar-zones', (req, res) ->
    northEast = JSON.parse req.query.northEast
    southWest = JSON.parse req.query.southWest
    query =
        match_all: {}
        filter:
            geo_shape:
                sectorBoundaries:
                    shape:
                        type: 'envelope'
                        coordinates: [
                            [northEast.longitude, northEast.latitude]
                            [southWest.longitude, southWest.latitude]
                        ]
                    relation: 'intersects'
    options =
        method: 'GET'
        json: query
        url: 'http://openify-api-staging.herokuapp.com/v0/datasets/3d21936a-db85-41ab-a0b4-b055dbe21467:1/data'
        qs:
            limit: 100
            apiKey: '77993f4a-e4cd-4403-b030-6f05b40d95cf'
            secretKey: 'ca5a7809-3d94-4951-b2df-024e0bf8bd3e'

    request options, (error, response, body) ->
        res.json body.data

app.get '/api/user-in-zone', (req, res) ->
    query =
        match_all: {}
        filter:
            geo_shape:
                sectorBoundaries:
                    shape:
                        type: 'point'
                        coordinates: [
                            req.query.longitude
                            req.query.latitude
                        ]
    options =
        method: 'GET'
        json: query
        url: 'http://openify-api-staging.herokuapp.com/v0/datasets/3d21936a-db85-41ab-a0b4-b055dbe21467:1/data'
        qs:
            apiKey: '77993f4a-e4cd-4403-b030-6f05b40d95cf'
            secretKey: 'ca5a7809-3d94-4951-b2df-024e0bf8bd3e'

    request options, (error, response, body) ->
        console.log body.data.length > 0, body.data
        res.json {data: (body.data.length > 0)}

app.get '/api/speed-limit', (req, res) ->
    getAddress = (latitude, longitude, callback) ->
        json = "{location:{latLng:{lat:#{latitude},lng:#{longitude}}}}"
        options =
            json: true
            url: "http://open.mapquestapi.com/geocoding/v1/reverse?key=#{process.env.MAPQUEST_API_KEY}&json=#{json}"

        request options, (err, response, body) ->
            if err
                callback err
            else
                if body.info.statuscode is 200 or body.info.statuscode is 0
                    callback null, body.results[0].locations[0].street
                else
                    callback new Error('Something went wrong with MapQuest')

    getSpeedLimit = (latitude, longitude, street, callback) ->
        query =
            sort: [
                {
                    _geo_distance:
                        geo:
                            lat: latitude
                            lng: longitude
                }
            ]
            query:
                match:
                    specifique: street

        options =
            method: 'GET'
            json: query
            url: 'http://openify-api-staging.herokuapp.com/v0/datasets/7bbe7e06-d820-4481-ada2-2ad9bd955106:1/data'
            qs:
                fields: 'limite'
                apiKey: '77993f4a-e4cd-4403-b030-6f05b40d95cf'
                secretKey: 'ca5a7809-3d94-4951-b2df-024e0bf8bd3e'

        request options, (err, response, body) ->
            callback null, body.data[0].fields.limite, street

    sendResponse = (err, limit, street) ->
        res.charset = 'utf-8'
        if err
            res.json 500, {error: err}
        else
            result =
                metadata:
                    note: 'Geocoding Courtesy of MapQuest'
                    fields: [
                        {
                            name: 'limit'
                            description: 'speed limit in meters per second'
                        }
                        {
                            name: 'street'
                            description: 'Name of the street as return by MapQuest'
                        }
                    ]
                data:
                    limit: limit
                    street: street
            res.json result

    tasks = [
        getAddress.bind(@, req.query.latitude, req.query.longitude)
        getSpeedLimit.bind(@, req.query.latitude, req.query.longitude)
    ]

    async.waterfall tasks, sendResponse

port = process.env.PORT | 3000

http.createServer(app).listen port, () ->
    console.log 'server waiting for requests...', port

module.exports = app
