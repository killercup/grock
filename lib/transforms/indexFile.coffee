###
# # Rename Index File
###

path = require 'path'
map = require 'map-stream'

module.exports = (indexFile) ->
  modifyFile = (file, cb) ->
    if file.originalRelative is indexFile
      file.path = path.join(file.cwd, 'index.html')
    
    cb(null, file)

  return map(modifyFile)
