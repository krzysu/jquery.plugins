/*global module:false*/
module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({

    lint: {
      files: [
        'grunt.js'
      ]
    },

    coffee: {
      main: {
        files: {
          "jquery.on-page-navigator.js": "jquery.on-page-navigator.js.coffee"
        }
      }
    },

    min: {
      main: {
        src: ['jquery.on-page-navigator.js'],
        dest: 'jquery.on-page-navigator.min.js'
      }
    },

    watch: { // for development run 'grunt watch'
      coffee: {
        files: ['*.coffee'],
        tasks: ['coffee:main']
      }
    }

  });

  // Default task. Prepare for deploy. Use before commit.
  grunt.registerTask('default', '');
  grunt.registerTask('build', 'lint coffee:main min:main');

  // plugin tasks
  grunt.loadNpmTasks('grunt-contrib');

};
