module.exports = function(grunt) {
  // load all grunt tasks
  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    watch: {
      js: {
        files: ['src/js/**/*.js', 'package.json'],
        tasks: ['build'],
        options: {
          spawn: false,
          livereload: true
        }
      },
      swf: {
        files: ['src/swf/*.swf'],
        tasks: ['copy:swf'],
        options: {
          spawn: false,
          livereload: true
        }
      }
    },
    concat: {
      options: {
        separator: ';'
      },
      dist: {
        src: ['src/js/**.js'],
        dest: 'dist/js/<%= pkg.name %>-<%= pkg.version %>.js'
      }
    },
    replace: {
      dist: {
        src: ['dist/js/*.js'],
        overwrite: true,
        replacements: [{
          from: /@NAME/g,
          to: '<%= pkg.name %>'
        }, {
          from: /@VERSION/g,
          to: '<%= pkg.version %>'
        }]
      },
      single: {
        src: ['demo/index.tpl'],
        dest: 'demo/index.html',
        // overwrite: true,
        replacements: [{
          from: /@NAME/g,
          to: '<%= pkg.name %>'
        }, {
          from: /@VERSION/g,
          to: '<%= pkg.version %>'
        }]
      },
      multiple: {
        src: ['demo/index-multiple.tpl'],
        dest: 'demo/index-multiple.html',
        // overwrite: true,
        replacements: [{
          from: /@NAME/g,
          to: '<%= pkg.name %>'
        }, {
          from: /@VERSION/g,
          to: '<%= pkg.version %>'
        }]
      }
    },
    copy: {
      css: {
        cwd: 'src/css',
        src: [ '*.css' ],
        dest: 'dist/css',
        expand: true
      },
      swf: {
        src: 'src/swf/*.swf',
        dest: 'dist/swf/<%= pkg.name %>-<%= pkg.version %>.swf'
      }
    },
    uglify: {
      options: {
        banner: '/*! <%= pkg.name %>-<%= pkg.version %> <%= grunt.template.today("yyyy-mm-dd HH:MM:ss") %> */\n',
        beautify: {
          'ascii_only': true
        },
        compress: {
          'global_defs': {
            'DEBUG': false
          },
          'dead_code': true
        }
      },
      dist: {
        files: {
          'dist/js/<%= pkg.name %>-<%= pkg.version %>.min.js': ['<%= concat.dist.dest %>']
        }
      }
    },
    qunit: {
      files: ['test/**/*.html']
    },
    jshint: {
      files: ['src/**/*.js'],
      options: {
        jshintrc: true
      }
    },
    yuidoc: {
      compile: {
        name: '<%= pkg.name %>',
        description: '<%= pkg.description %>',
        version: '<%= pkg.version %>',
        options: {
          paths: 'src/js',
          outdir: 'doc'
        }
      }
    },
    clean:{
      dist: {
        src: [ 'dist/**' ]
      },
      doc: {
        src: [ 'doc/**' ]
      }
    }
  });

  grunt.registerTask('build', ['clean', 'concat', 'replace', 'copy', 'uglify', 'yuidoc']);

  grunt.registerTask('test', ['jshint', 'qunit']);

  grunt.registerTask('default', ['test', 'build', 'watch']);

};
