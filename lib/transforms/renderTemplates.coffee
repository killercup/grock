###
# # Render Templates
#
# Expects a Jade template file as `template.jade` in the style's directory.
###

fs = require 'fs'
path = require 'path'
gutil = require 'gulp-util'
map = require 'map-stream'
Buffer = require('buffer').Buffer

jade = require 'jade'

module.exports = ({style}) ->
  templateFile = fs.readFileSync path.join(
    __dirname, '..', '..', 'styles', style, 'template.jade'
  ), 'utf-8'

  render = jade.compile(templateFile)

  modifyFile = (file, cb) ->
    cb(null, file) unless file.segments?.length

    # ## Variables accessable in template
    templateContext =
      pageTitle: path.basename file.path
      segments: file.segments
      targetPath: file.relative

    pathChunks = path.dirname(file.relative).split(/[\/\\]/)
    if pathChunks.length == 1 && pathChunks[0] == '.'
      templateContext.relativeRoot = ''
    else
      templateContext.relativeRoot = "#{pathChunks.map(-> '..').join '/'}/"

    file.contents = new Buffer render(templateContext)

    file.path = gutil.replaceExtension(file.path, ".html")

    cb(null, file)
    return

  return map(modifyFile)
