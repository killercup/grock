colors = require 'chalk'

verbose = false

setVerbose = (val=true) ->
  verbose = !!val

log = ->
  sig = "[" + colors.green("grock") + "]"
  args = Array::slice.call(arguments)
  args.unshift sig
  console.log.apply console, args
  this

logVerbose = ->
  return unless verbose
  log.apply this, arguments

module.exports = log
module.exports.verbose = logVerbose
module.exports.setVerbose = setVerbose