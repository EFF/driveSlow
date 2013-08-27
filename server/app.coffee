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

app.get '/api/speed-limit', (req, res) ->
    getAddress = (latitude, longitude, callback) ->
        key = 'Fmjtd%7Cluub2g01n9%2C8a%3Do5-9ub5gy'
        json = "{location:{latLng:{lat:#{latitude},lng:#{longitude}}}}"
        options =
            url: "http://open.mapquestapi.com/geocoding/v1/reverse?key=#{key}&json=#{json}"
        request options, (err, response, body) ->
            if err
                callback err
            else
                body = JSON.parse body
                console.log body
                if body.info.statuscode is 200 or body.info.statuscode is 0
                    callback null, body.results[0].locations[0].street
                else
                    callback new Error('Something went wrong with MapQuest')

    getSpeedLimit = (street, callback) ->
        callback null, 30, street

    sendResponse = (err, limit, street) ->
        res.charset = 'utf-8'
        console.log err, limit, street
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
        getSpeedLimit
    ]

    async.waterfall tasks, sendResponse

port = process.env.PORT | 3000

http.createServer(app).listen port, () ->
    console.log 'server waiting for requests...'

module.exports = app
