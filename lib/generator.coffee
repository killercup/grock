###
# # Documetation Generator
###

# ## NPM Modules
path = require 'path'
fs = require 'fs'
vfs = require 'vinyl-fs'
map = require 'map-stream'
prettyTime = require 'pretty-hrtime'
colors = require 'chalk'
Q = require 'q'

# ## Local Modules
t = require './transforms'
log = require './utils/log'

# ## Helpers

# ### Calculate Runtime
START = process.hrtime()

duration = (start) ->
  colors.magenta prettyTime process.hrtime(start)

# ## The Glorious Generator
module.exports = (opts) ->
  {glob, style, out, verbose, start, index, root} = opts
  verbose or= false
  start or= START

  log 'Beginning to process', (if verbose then glob else ''), duration(start)
  deferred = Q.defer()

  # Load Style
  style = require "../styles/#{style}"

  # Create output directory
  dest = out or 'docs/'
  log 'Writing to', dest
  unless fs.existsSync dest
    fs.mkdirSync dest

  # ### Processing Pipeline
  vfs.src glob, base: root
  .pipe map (file, cb) ->
    if file.stat.isFile() then cb(null, file) else cb()
  .pipe map (file, cb) ->
    # Save start time
    file.timingStart = process.hrtime()
    cb(null, file)
  .pipe t.getLanguage()
  .pipe t.splitCodeAndComments()
  .pipe t.highlight()
  .pipe t.renderDocTags()
  .pipe t.markdownComments()
  .pipe t.renderTemplates(style: style, repositoryUrl: opts['repository-url'])
  .pipe t.indexFile(index)
  .pipe vfs.dest(dest)
  .pipe t.renderFileTree(path.join(dest, "toc.js"), verbose: verbose)
  .pipe map (file, cb) ->
    # Log process duration
    log file.relative, duration(file.timingStart) if verbose
    cb(null, file)
  .on 'error', deferred.reject
  .on 'end', ->
    # ### Process Style
    assetsTiming = process.hrtime()
    style.copy(dest: dest)
    .then ->
      log "Style copied", duration(assetsTiming) if verbose
      log "Done.", colors.magenta("Generated in"), duration(start)
      deferred.resolve()
    .then null, (err) ->
      log colors.red("It exploded!")
      console.log(err) if verbose
      deferred.reject()

  return deferred.promise