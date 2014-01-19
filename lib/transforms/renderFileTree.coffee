###
# # Write JSON File Tree
###

fs = require 'fs'
path = require 'path'
through = require 'through2'

log = require '../utils/log'

module.exports = (fileName, opt={}) ->
  unless fileName
    throw new PluginError("Render File Tree", "Missing fileName option")

  output = fs.createWriteStream(fileName)
  output.write "window.#{opts.varName or 'files'} = [\n"
  first = true

  bufferContents = (file, enc, cb) ->
    output.write (if first then '' else ',\n') + JSON.stringify({
      path: file.relative
      originalName: path.basename file.originalPath
      originalPath: file.originalRelative
      name: path.basename file.path
      title: file.extra?.toc?[0]?.title
      toc: file.extra?.toc
    }, false, 2)
    first = false

    cb null, file

  endStream = (cb) ->
    output.write "\n];"
    if opt.verbose
      log "File tree written to #{path.basename fileName}"
    cb()

  through.obj bufferContents, endStream
