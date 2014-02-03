###
# # Render Doc Tags to Markdown
###

Buffer = require('buffer').Buffer
map = require('event-stream').map

render = require '../utils/processDocTags'

module.exports = (options) ->
  modifyFile = (file, cb) ->
    return cb(null, file) unless file.segments?.length

    render.parseDocTags(file.segments)
    .then(render.markdownDocTags)
    .then(render.renderDocTags)
    .then ->
      cb(null, file)
    .then null, (err) ->
      err.file = file.relative
      cb(err)

    return

  return map(modifyFile)
