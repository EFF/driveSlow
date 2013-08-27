path = require 'path'
module.exports = (grunt) ->
    config =
        coffee:
            compile:
                files: [{
                    expand: true
                    cwd: './client/'
                    src: ['./**/*.coffee']
                    dest: './build/javascripts/'
                    ext: '.js'
                }]
                options:
                    bare: true
        browserify:
            basic:
                src: './build/javascripts/app.js'
                dest: './build/compiled.js'
        watch:
            client:
                tasks: ['compile-client']
                files: ['./client/**/*.coffee']
        nodemon:
            dev:
                options:
                    file: './server/app.coffee'
                    watchedFolders: ['server']
                    watchedExtensions: ['coffee']
        concurrent:
            dev:
                tasks: ['nodemon:dev', 'watch:client']
                options:
                    logConcurrentOutput: true

    grunt.initConfig config

    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-browserify'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-nodemon'
    grunt.loadNpmTasks 'grunt-concurrent'

    grunt.registerTask 'compile-client', ['coffee:compile', 'browserify']

    grunt.registerTask 'default', ['compile-client', 'concurrent:dev']
