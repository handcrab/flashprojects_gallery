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

  # Dependencies
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-sass'

  grunt.registerTask 'default', ['coffee']