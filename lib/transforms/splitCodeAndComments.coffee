###
# # Split Code and Comments
###

Buffer = require('buffer').Buffer
map = require('event-stream').map

seperator = require '../utils/seperator'

module.exports = (options) ->
  modifyFile = (file, cb) ->
    try
      str = file.contents.toString('utf8')
      file.segments = seperator str, file.extra.lang
    catch e
      return cb(new Error("seperator: Error seperating code and comments #{e}"))

    return cb(null, file)

  return map(modifyFile)
