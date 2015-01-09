fs = require 'fs'
async = require 'async'
Q = require 'q'

module.exports = (paths) ->
  deferred = Q.defer()

  paths or= []
  if typeof paths is typeof ''
    paths = [paths]

  if paths.length
    async.map paths, fs.readFile, (err, contents) ->
      if err
        return deferred.reject "file #{err.path} couldn`t be read"
      deferred.resolve contents.map (item) ->
        item.toString()
  else
    deferred.resolve([''])

  deferred.promise
