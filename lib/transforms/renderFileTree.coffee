###
# # Write JSON File Tree
###

fs = require 'fs'
path = require 'path'

through = require('event-stream').through

log = require '../utils/log'
getTitle = require '../utils/getTitleFromToc'

module.exports = (fileName, opts={}) ->
  unless fileName
    throw new Error("Render File Tree: Missing fileName option")

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
      title: file.extra?.title or= getTitle(file)
      toc: file.extra?.toc
    }, false, 2)
    first = false

    @emit('data', file)

  endStream = (cb) ->
    output.push fileSuffix
    fs.writeFile fileName, output.join(''), (err) =>
      return cb(err) if err
      log.verbose "File tree written to #{path.basename fileName}"
      @emit('end')

  through bufferContents, endStream
