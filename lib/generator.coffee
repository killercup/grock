###
# # Documetation Generator
###

# ## NPM Modules
fs = require 'fs'
vfs = require 'vinyl-fs'
map = require 'map-stream'
prettyTime = require 'pretty-hrtime'
gutil = require 'gulp-util'

# ## Local Modules
t = require './transforms'
log = require './utils/log'

# ## Helpers

# ### Calculate Runtime
START = process.hrtime()

duration = (start) ->
  gutil.colors.magenta(prettyTime(process.hrtime(start)))

# ### Copy Style Files
copyStyleAssets = (style, dest) ->
  copy = require "../styles/#{style}/copy"
  copy(dest: dest)

# ## The Glorious Generator
module.exports = ({src, style, dest, verbose, start}) ->
  start or= START
  log 'Beginning to process', src, duration(start)

  # Create output directory
  dest or= 'docs/'
  unless fs.existsSync dest
    fs.mkdirSync dest

  # ### Processing Pipeline
  vfs.src(src)
  .pipe(map (file, cb) ->
    # Save start time
    file.timingStart = process.hrtime()
    cb(null, file)
  )
  .pipe(t.getLanguage())
  .pipe(t.splitCodeAndComments())
  .pipe(t.highlight())
  .pipe(t.renderDocTags())
  .pipe(t.markdownComments())
  .pipe(t.renderTemplates(style: style))
  .pipe(vfs.dest('docs/'))
  .pipe(t.renderFileTree("docs/toc.js", verbose: verbose or true))
  .pipe(map (file, cb) ->
    # #### Log process duration
    log file.relative, duration(file.timingStart)
    cb(null, file)
  )
  .on 'end', ->
    # ### Process Style
    assetsTiming = process.hrtime()
    copyStyleAssets(style, 'docs/')
    .then ->
      log "Style copied", duration(assetsTiming)
      log "Done.", gutil.colors.magenta("Generated in"), duration(start)
    .then null, ->
      log gutil.colors.red("Shit exploded!")
      process.exit(1)
