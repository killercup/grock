vfs = require 'vinyl-fs'
map = require 'map-stream'

prettyTime = require 'pretty-hrtime'
gutil = require 'gulp-util'
log = require '../lib/utils/log'

duration = (start) ->
  gutil.colors.magenta(prettyTime(process.hrtime(start)))

callCompile = (file, cb) ->
  compile = require "./#{file.relative}"

  compile()
  .then(->
    log "compiled promise", file.relative
    cb(null, file)
  )
  .then null, -> cb("failed")

compileAll = ->
  vfs.src("#{__dirname}/*/compile.coffee")
  .pipe(map (file, cb) ->
    log 'compiling', file.relative
    file.timingStart = process.hrtime()
    cb(null, file)
  )
  .pipe(map callCompile)
  .pipe(map (file, cb) ->
    log "compiled", file.relative, duration(file.timingStart)
    cb(null, file)
  )

compileAll()