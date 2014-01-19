path = require 'path'
vfs = require 'vinyl-fs'

Q = require 'q'
ee = require 'streamee'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
scss = require 'gulp-sass'

module.exports = (options={}) ->
  finalDest = options.dest or "#{__dirname}/compiled"

  deferLibs = Q.defer()
  deferScripts = Q.defer()
  deferStyles = Q.defer()

  # JS
  jsLibsPath = "#{__dirname}/assets/js/libs"
  jsPath = "#{__dirname}/assets/js"

  vfs.src("#{jsLibsPath}/**/*.js")
  .pipe(concat('libs.js'))
  .pipe(vfs.dest(finalDest))
  .on 'end', deferLibs.resolve

  ee.interleave([
    vfs.src("#{jsPath}/*.js")
    vfs.src("#{jsPath}/*.coffee").pipe(coffee())
  ])
  .pipe(concat('behavior.js'))
  .pipe(uglify(output: {comments: /^!|@preserve|@license|@cc_on/i}))
  .pipe(vfs.dest(finalDest))
  .on 'end', deferScripts.resolve

  # SCSS
  vfs.src("#{__dirname}/assets/css/style.scss")
  .pipe(scss
    includePaths: ["#{__dirname}/assets/css"]
    outputStyle: 'compressed'
    sourceComments: 'none'
  )
  .pipe(vfs.dest(finalDest))
  .on 'end', deferStyles.resolve

  return Q.allSettled [
    deferLibs.promise
    deferScripts.promise
    deferStyles.promise
  ]
