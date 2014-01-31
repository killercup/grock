###
# # Rename Index File
###

path = require 'path'
map = require('event-stream').map

module.exports = (indexFile='') ->
  # Process only one index file
  found = false

  modifyFile = (file, cb) ->
    if not found and (file.originalRelative is indexFile)
      file.path = path.join(file.cwd, 'index.html')
      found = true
    
    cb(null, file)

  return map(modifyFile)
