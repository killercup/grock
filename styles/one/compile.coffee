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
  deferScripts = Q.when(true)
  deferStyles = Q.defer()
  deferTemplates = Q.defer()

  # Jade
  templateFile = fs.readFileSync path.join(__dirname, 'assets', 'template.html')
  render = _.template templateFile, null, variable: 'data'

  fs.writeFile path.join(finalDest, 'template.js'),
    "var _ = require('lodash');\nmodule.exports = #{render.source};",
    deferTemplates.makeNodeResolver()

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
