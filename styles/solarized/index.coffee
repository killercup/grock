path = require 'path'

module.exports =
  name: "Solarized"
  getTemplate: ->
    require path.join(__dirname, 'compiled', 'template.js')
  copy: (opts) -> require('./copy')(opts)
  compile: (opts) -> require('./compile')(opts)
