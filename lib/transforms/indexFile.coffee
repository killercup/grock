###
# # Rename Index File
###

path = require 'path'
map = require('event-stream').map

module.exports = (indexFile='') ->
  # Process only one index file
  found = false

  modifyFile = (file, cb) ->
    filePath = file.originalRelative or file.relative
    if not found and (filePath is indexFile)
      file.path = path.join(file.cwd, 'index.html')
      found = true
    
    cb(null, file)

  return map(modifyFile)
