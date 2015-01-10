fs = require 'fs'
Q = require 'q'
_ = require 'lodash'

readFile = Q.denodeify(fs.readFile)

module.exports = (paths) ->
  paths or= []
  if _.isString(paths)
    paths = [paths]

  if paths.length
    return Q.all paths.map (path) -> readFile(path)
    .then (contents) -> Q.when contents.map (item) -> item.toString()
    .catch (err) -> Q.reject("file #{err.path} couldn't be read")
  else
    return Q.when([''])
