###
# # Write JSON File Tree
###

fs = require 'fs'
path = require 'path'
through = require 'through2'

JSONStream = require 'JSONStream'

module.exports = (fileName, opt={}) ->
  unless fileName
    throw new PluginError("Render File Tree", "Missing fileName option")

  fileTree = JSONStream.stringify()
  output = fileTree.pipe fs.createWriteStream(fileName)

  bufferContents = (file) ->
    fileTree.push
      path: file.relative
      name: path.basename file.path
      title: file.extra?.toc?[0]?.title
      toc: file.extra?.toc

  endStream = ->
    fileTree.end()

  through bufferContents, endStream
