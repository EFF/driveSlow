stylus = require 'stylus'
express = require 'express'
path = require 'path'
http = require 'http'

publicDirectory = path.join __dirname, '../build'
stylusSource = path.join __dirname, '../client/stylesheets'
stylusDestination = path.join __dirname, '../build/stylesheets'

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
    res.charset = 'utf-8'
    result =
        metadata:
            fields: [
                {
                    name: 'limit'
                    description: 'speed limit in meters per second'
                }
                {
                    name: 'streetName'
                    description: 'Name of the street'
                }
            ]
        data:
            limit: 30 * 1000 / 3600
            streetName: "Rue des Érables"
    res.json result

port = process.env.PORT | 3000

http.createServer(app).listen port, () ->
    console.log 'server waiting for requests...'

module.exports = app
