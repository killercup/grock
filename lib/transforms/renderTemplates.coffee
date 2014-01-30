###
# # Render Templates
#
# Renders HTML files by using the style's render function (using
# `style.getTemplate()`).
###

fs = require 'fs'
path = require 'path'
map = require 'map-stream'
Buffer = require('buffer').Buffer

module.exports = ({style, repositoryUrl}) ->
  render = style.getTemplate()

  modifyFile = (file, cb) ->
    cb(null, file) unless file.segments?.length

    file.originalPath = file.path
    file.originalRelative = file.relative
    file.path = file.path + ".html"

    # ## Variables accessable in template
    templateContext =
      pageTitle: path.basename file.originalRelative
      segments: file.segments
      targetPath: file.originalRelative
      repositoryUrl: repositoryUrl

    pathChunks = path.dirname(file.relative).split(/[\/\\]/)
    if pathChunks.length == 1 && pathChunks[0] == '.'
      templateContext.relativeRoot = ''
    else
      templateContext.relativeRoot = "#{pathChunks.map(-> '..').join '/'}/"

    try
      rendered = render(templateContext)
    catch e
      return cb(e)

    file.contents = new Buffer rendered

    cb(null, file)
    return

  return map(modifyFile)
