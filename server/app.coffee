express = require 'express'
path = require 'path'
http = require 'http'

publicDirectory = path.join __dirname, '../build'

app = express()
app.configure () ->
    app.use express.compress()
    app.use express.static(publicDirectory)

    app.set 'views', __dirname + '/views'
    app.set 'view engine', 'jade'
    app.disable 'x-powered-by'
    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use app.router
    app.use express.static(publicDirectory)

    app.get '/', (req, res) ->
        res.render 'index'
    app.get '/partials/:name', (req, res) ->
        res.render 'partials/' + req.params.name.replace('.html', '.jade')

module.exports = app
