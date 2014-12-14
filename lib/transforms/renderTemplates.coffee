###
# # Render Templates
#
# Renders HTML files by using the style's render function (using
# `style.getTemplate()`).
###

fs = require 'fs'
path = require 'path'

Buffer = require('buffer').Buffer
map = require('event-stream').map

getTitle = require '../utils/getTitleFromToc'
createPublicURL = require '../utils/createPublicURL'

module.exports = ({style, repositoryUrl, externals}) ->
  render = style.getTemplate()
  publicURL = createPublicURL(repositoryUrl)

  modifyFile = (file, cb) ->
    return cb(null, file) unless file.segments?.length

    file.originalPath = file.path
    file.originalRelative = file.relative
    file.path = file.path + ".html"

    externals.scripts or= []
    externals.styles or= []

    # ## Variables accessable in template
    templateContext =
      pageTitle: path.basename file.originalRelative
      pageHeadline: file.extra?.title or= getTitle(file)
      segments: file.segments
      targetPath: file.originalRelative
      publicURL: publicURL(file.originalRelative)
      externals: externals

    pathChunks = path.dirname(file.relative).split(/[\/\\]/)
    if pathChunks.length == 1 && pathChunks[0] == '.'
      templateContext.relativeRoot = ''
    else
      templateContext.relativeRoot = "#{pathChunks.map(-> '..').join '/'}/"

    try
      rendered = render(templateContext)
    catch err
      err.file = file.relative
      return cb(err)

    file.contents = new Buffer rendered

    cb(null, file)
    return

  return map(modifyFile)
