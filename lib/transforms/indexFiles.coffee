###
# # Rename Index File
###

path = require 'path'
map = require('event-stream').map

module.exports = (indexFile) ->
  modifyFile = (file, cb) ->
    fileName = path.basename(file.originalRelative or file.relative)
    if fileName is indexFile
      file.path = path.join(path.dirname(file.path), 'index.html')
    
    cb(null, file)

  # Skip checks where there is nothing to be checked
  if (not indexFile) or (indexFile is '')
    modifyFile = (file, cb) -> cb(null, file)

  return map(modifyFile)
