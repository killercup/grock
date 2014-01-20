###
# # Render Doc Tags to Markdown
###

Buffer = require('buffer').Buffer
map = require 'map-stream'

render = require '../utils/processDocTags'

module.exports = (options) ->
  modifyFile = (file, cb) ->
    cb(null, file) unless file.segments?.length

    render.parseDocTags(file.segments)
    .then(render.markdownDocTags)
    .then(render.renderDocTags)
    .then ->
      cb(null, file)
    .then null, cb

    return

  return map(modifyFile)
