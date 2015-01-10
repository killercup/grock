###
# # Documetation Generator
###

# ## NPM Modules
path = require 'path'
fs = require 'fs'
vfs = require 'vinyl-fs'
map = require('event-stream').map
prettyTime = require 'pretty-hrtime'
colors = require 'chalk'
Q = require 'q'

# ## Local Modules
t = require './transforms'
log = require './utils/log'
plumber = require './utils/plumber'
getExtraContent = require './utils/getExtraContent'

# ## Helpers

# ### Calculate Runtime
START = process.hrtime()

duration = (start) ->
  colors.magenta prettyTime process.hrtime(start)

# ## The Glorious Generator
module.exports = (opts) ->
  {glob, style, out, verbose, start, index, indexes, root} = opts
  verbose or= false
  log.setVerbose(verbose)
  start or= START

  log 'Beginning to process', (if verbose then glob else ''), duration(start)

  # Load Style
  style = require "../styles/#{style}"

  repositoryUrl = opts['repository-url']

  externals =
    styles: []
    scripts: []

  # get extra styles first
  getExtraContent(opts['ext-styles'])
  .then (styles) ->
    externals.styles = styles
    return getExtraContent(opts['ext-scripts'])
  .catch (err) ->
    # failed to get styles, continue with scripts
    log colors.red err
    return getExtraContent(opts['ext-scripts'])
  # and extra scripts then
  .then (scripts) ->
    externals.scripts = scripts

    # Create output directory
    dest = out or 'docs/'
    log 'Writing to', dest
    unless fs.existsSync dest
      fs.mkdirSync dest

    deferred = Q.defer()

    # ### Processing Pipeline
    vfs.src glob, base: root
    .pipe plumber()
    .pipe map (file, cb) ->
      if file.stat.isFile() then cb(null, file) else cb()
    .pipe map (file, cb) ->
      # Save start time
      file.timingStart = process.hrtime()
      cb(null, file)
    .pipe t.getLanguage()
    .pipe t.splitCodeAndComments(requireWhitespaceAfterToken: opts['whitespace-after-token'])
    .pipe t.highlight()
    .pipe t.renderDocTags()
    .pipe t.markdownComments()
    .pipe t.renderTemplates(style: style, repositoryUrl: repositoryUrl, externals: externals)
    .pipe t.indexFile(index)
    .pipe t.indexFiles(indexes)
    .pipe vfs.dest(dest)
    .pipe t.renderFileTree(path.join(dest, "toc.js"))
    .pipe map (file, cb) ->
      # Log process duration
      log.verbose file.relative, duration(file.timingStart)
      cb(null, file)
    .on 'error', deferred.reject
    .on 'end', ->
      # ### Process Style
      assetsTiming = process.hrtime()
      style.copy(dest: dest)
      .then ->
        log.verbose "Style copied", duration(assetsTiming)
        deferred.resolve()
      .catch deferred.reject

    return deferred.promise
  .then (result) ->
    log "Done.", colors.magenta("Generated in"), duration(start)
  .catch (err) ->
    log colors.red "It exploded!", err.message or ''
    log.verbose err.stack or err
