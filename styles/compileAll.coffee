path = require 'path'
vfs = require 'vinyl-fs'
map = require 'map-stream'

prettyTime = require 'pretty-hrtime'
gutil = require 'gulp-util'
log = require '../lib/utils/log'

duration = (start) ->
  gutil.colors.magenta(prettyTime(process.hrtime(start)))

indexToStyleName = (filePath) ->
  path.dirname(filePath).split('/').pop()

callCompile = (file, cb) ->
  style = require "./#{file.relative}"

  style.compile()
  .then -> cb(null, file)
  .then null, cb

compileAll = ->
  vfs.src("#{__dirname}/*/index.{js,coffee}")
  .pipe(map (file, cb) ->
    log 'compiling', indexToStyleName(file.relative)
    file.timingStart = process.hrtime()
    cb(null, file)
  )
  .pipe(map callCompile)
  .pipe(map (file, cb) ->
    log "compiled", indexToStyleName(file.relative), duration(file.timingStart)
    cb(null, file)
  )

compileAll()