# # Compile Solarized Assets

path = require 'path'
fs = require 'fs'
vfs = require 'vinyl-fs'
Q = require 'q'
_ = require 'lodash'

es = require('event-stream')

coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
scss = require 'gulp-sass'

module.exports = (options={}) ->
  finalDest = options.dest or path.join(__dirname, 'compiled')

  deferLibs = Q.defer()
  deferScripts = Q.defer()
  deferStyles = Q.defer()
  deferTemplates = Q.defer()

  # Jade
  templateFile = fs.readFileSync path.join(__dirname, 'assets', 'template.html')
  render = _.template templateFile, null, variable: 'data'

  fs.writeFile path.join(finalDest, 'template.js'),
    "var _ = require('lodash');\nmodule.exports = #{render.source};",
    deferTemplates.makeNodeResolver()

  # JS
  jsLibsPath = "#{__dirname}/assets/js/libs"
  jsPath = "#{__dirname}/assets/js"

  vfs.src("#{jsLibsPath}/**/*.js")
  .pipe(concat('libs.js'))
  .pipe(vfs.dest(finalDest))
  .on 'error', deferLibs.reject
  .on 'end', deferLibs.resolve

  es.merge(
    vfs.src("#{jsPath}/*.js")
    vfs.src("#{jsPath}/*.coffee").pipe(coffee())
  )
  .pipe(concat('behavior.js'))
  .pipe(uglify(output: {comments: /^!|@preserve|@license|@cc_on/i}))
  .pipe(vfs.dest(finalDest))
  .on 'error', deferScripts.reject
  .on 'end', deferScripts.resolve

  # SCSS
  vfs.src("#{__dirname}/assets/css/style.scss")
  .pipe(scss
    includePaths: ["#{__dirname}/assets/css"]
    outputStyle: 'compressed'
    sourceComments: 'none'
  )
  .pipe(vfs.dest(finalDest))
  .on 'error', deferStyles.reject
  .on 'end', deferStyles.resolve

  return Q.allSettled [
    deferLibs.promise
    deferScripts.promise
    deferStyles.promise,
    deferTemplates.promise
  ]
