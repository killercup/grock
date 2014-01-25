###
# # Write JSON File Tree
###

fs = require 'fs'
path = require 'path'
through = require 'through2'
_ = require 'lodash'

log = require '../utils/log'

module.exports = (fileName, opts={}) ->
  unless fileName
    throw new PluginError("Render File Tree", "Missing fileName option")

  filePrefix = opts.filePrefix or "window.#{opts.varName or 'files'} = [\n"
  fileSuffix = opts.fileSuffix or "\n];"

  output = []
  output.push filePrefix
  first = true

  bufferContents = (file, enc, cb) ->
    output.push (if first then '' else ',\n') + JSON.stringify({
      path: file.relative
      originalName: path.basename file.originalPath
      originalPath: file.originalRelative
      name: path.basename file.path
      lang: file.extra?.lang?.highlightJS or file.extra?.lang?.pygmentsLexer
      title: _.find(file.extra?.toc, level: 1)?.title
      toc: file.extra?.toc
    }, false, 2)
    first = false

    cb null, file

  endStream = (cb) ->
    output.push fileSuffix
    fs.writeFile fileName, output.join(''), (err) ->
      return cb(err) if err
      if opts.verbose
        log "File tree written to #{path.basename fileName}"
      cb(null)

  through.obj bufferContents, endStream
