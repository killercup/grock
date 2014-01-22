colors = require 'chalk'

module.exports = ->
  sig = "[" + colors.green("grock") + "]"
  args = Array::slice.call(arguments)
  args.unshift sig
  console.log.apply console, args
  this