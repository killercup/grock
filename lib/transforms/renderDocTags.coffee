###
# # Render Doc Tags to Markdown
###

Buffer = require('buffer').Buffer
map = require 'map-stream'

render = require '../utils/processDocTags'

module.exports = (options) ->
  # Annotate an array of segments by running their comments through
  # [marked](https://github.com/chjj/marked).
  modifyFile = (file, cb) ->
    # No comment(s)
    cb(null, file) unless file.segments?.length

    render.parseDocTags(file.segments)
    .then(render.markdownDocTags)
    .then(render.renderDocTags)
    .then ->
      cb(null, file)
    .then null, cb

    return

  return map(modifyFile)
