#!/bin/sh
./node_modules/.bin/grunt compile-client && ./node_modules/.bin/coffee ./server/app.coffee
