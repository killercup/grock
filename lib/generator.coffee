vfs = require 'vinyl-fs'
map = require 'map-stream'
prettyTime = require 'pretty-hrtime'
gutil = require 'gulp-util'

t = require './transforms'
log = require './utils/log'

START = process.hrtime()

duration = (start) ->
  gutil.colors.magenta(prettyTime(process.hrtime(start)))

compileStyleAssets = (style, dest) ->
  compile = require "../styles/#{style}/copy"
  compile(dest: dest)

module.exports = ({src, style}) ->
  log 'Rendering documenation for', src

  vfs.src(src)
  .pipe(map (file, cb) ->
    file.timingStart = process.hrtime()
    cb(null, file)
  )
  .pipe(t.getLanguage())
  .pipe(t.splitCodeAndComments())
  .pipe(t.highlight())
  .pipe(t.markdownComments())
  .pipe(t.renderTemplates(style: style))
  .pipe(vfs.dest('docs/'))
  # .pipe(t.renderFileTree("docs/assets/toc.json"))
  .pipe(map (file, cb) ->
    log file.relative, duration(file.timingStart)
    cb(null, file)
  )
  .on 'end', ->
    assetsTiming = process.hrtime()
    compileStyleAssets(style, 'docs/')
    .then ->
      log "Style copied", duration(assetsTiming)
      log "Done.", gutil.colors.magenta("Generated in"), duration(START)
    .then null, ->
      log gutil.colors.red("Shit exploded!")
      process.exit(1)
