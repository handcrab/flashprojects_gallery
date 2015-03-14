module.exports = (grunt) ->
  # Constants
  BUILD_PATH = 'build'
  APP_PATH = 'app'

  # Project configuration
  grunt.initConfig
    coffee:
      options:
        bare: true
      compile: 
        expand: true
        cwd: "#{APP_PATH}/scripts"
        src: ['**/*.coffee']
        dest: "#{BUILD_PATH}/js"
        ext: '.js'

    jade:
      compile:
        options:
          pretty: true
          data:
            debug: true
        files: [
          expand: true
          cwd: APP_PATH
          src: ['**/*.jade']
          dest: BUILD_PATH
          ext: '.html'
        ]

    sass:
      dist:
        files: [
          expand: true
          cwd: "#{APP_PATH}/stylesheets"
          src: ['**/*.sass', '**/*.scss']
          dest: "#{BUILD_PATH}/css"
          ext: '.css'
        ]

    copy:
      img:
        files: [
          expand: true
          cwd: "#{APP_PATH}/images/"
          src: '**'
          dest: "#{BUILD_PATH}/img/"
        ]
      vendorcss:
        files: [
          expand: true
          cwd: "#{APP_PATH}/stylesheets/vendor"
          src: '**'
          dest: "#{BUILD_PATH}/css/vendor"
        ]

    watch:
      options:
        livereload: true
      scripts:
        files: ["#{APP_PATH}/scripts/*.coffee"]
        tasks: ['coffee:compile']
        options:
          spawn: false
      stylesheets:
        files: [
          "#{APP_PATH}/stylesheets/*.sass"
          "#{APP_PATH}/stylesheets/*.scss"
        ]
        tasks: ['sass']
        options:
          spawn: false
      html:
        files: ["#{APP_PATH}/*.jade"]
        tasks: ['jade:compile']
        options:
          spawn: false

    connect:
      server:
        options:
          port: 9000
          keepalive: true
          debug: true
          livereload: true
          base: BUILD_PATH # root

  # Dependencies
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-connect'

  grunt.registerTask 'default', ['watch']
  grunt.registerTask 'build',
    ['coffee:compile', 'sass', 'jade:compile', 'copy']