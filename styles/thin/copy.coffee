path = require 'path'
vfs = require 'vinyl-fs'
Q = require 'q'

module.exports = ({dest}) ->
  compilePath = "#{__dirname}/compiled"
  finalDest = path.join(dest, 'assets')
  deferCopy = Q.defer()

  vfs.src("#{compilePath}/*")
  .pipe(vfs.dest(finalDest))
  .on 'end', deferCopy.resolve

  return deferCopy.promise
