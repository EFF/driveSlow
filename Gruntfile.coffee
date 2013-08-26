path = require 'path'
module.exports = (grunt) ->
    config =
        coffee:
            compile:
                files: [{
                    expand: true
                    cwd: './scripts/'
                    src: ['./**/*.coffee']
                    dest: './build/javascripts/'
                    ext: '.js'
                }]
                options:
                    bare: true
        
        browserify:
            basic:
                src: './build/javascripts/app.js'
                dest: './build/bundle.js'
        jade:
            compile:
                options:
                    data:
                        debug: true
                files: [{
                    expand: true
                    cwd: './views/'
                    src: '**/*.jade'
                    dest: './build/views/'
                    ext: '.html'
                    }]
        sass:
            dist:
                files:
                    './build/style.css': ['./style/**/*.sass']
                options:
                    noCache: true

        express:
            custom:
                options:
                    port: 3000
                    server: path.resolve './server/app'


    grunt.initConfig config

    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-browserify'
    grunt.loadNpmTasks 'grunt-contrib-jade'
    grunt.loadNpmTasks 'grunt-contrib-sass'
    grunt.loadNpmTasks 'grunt-express'

    grunt.registerTask 'default', ['coffee:compile', 'browserify', 'express:custom', 'express-keepalive']
