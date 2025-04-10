module.exports = function(grunt) {
  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    requirejs: {
      compile: {
        options:{
            baseUrl: './js/client',
            mainConfigFile:'js/client/main.js',
            out:'js/client/<%= pkg.name %>.min.js',
            include: ['main','text'],
            preserveLicenseComments: false,
            "optimize": "uglify2"
        }
      }
    },

  coffee: {
      coffee_to_js:{
          options:{
            bare: true
          },
          expand: true,
          flatten: false,
          src: ["**/*.coffee"],
          ext: ".js"

}
  }

  });

  // Load the plugin that provides the "uglify" task.
//  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-requirejs');
  grunt.loadNpmTasks('grunt-contrib-coffee');


  grunt.registerTask('build', ['coffee','requirejs'])

  grunt.registerTask('default', ['build']);






  // Default task(s).

// EXAMPLE
//  grunt.registerTask("default",function(){
//      grunt.log.writeln("Hello, "+grunt.config.get('person').name)
//  })
}