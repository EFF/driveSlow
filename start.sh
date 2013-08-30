#!/bin/sh
./node_modules/.bin/grunt compile-client && coffee ./server/app.coffee
