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

  # Dependencies
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-sass'

  grunt.registerTask 'default', ['watch']
  grunt.registerTask 'compile', ['coffee:compile', 'sass', 'jade:compile']