###
# # Split Code and Comments
###

map = require 'map-stream'
Buffer = require('buffer').Buffer

seperator = require '../utils/seperator'

module.exports = (options) ->
  modifyFile = (file, cb) ->
    str = file.contents.toString('utf8')

    try
      file.segments = seperator str, file.extra.lang
    catch e
      return cb(new Error("seperator: Error seperating code and comments #{e}"))

    return cb(null, file)

  return map(modifyFile)
