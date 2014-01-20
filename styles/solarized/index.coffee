module.exports =
  name: "Solarized"
  template: "#{__dirname}/template.jade"
  copy: (opts) -> require('./copy')(opts)
  compile: (opts) -> require('./compile')(opts)
