_ = require 'lodash'

module.exports = (file) ->
  title = _.find(file.extra?.toc, level: 1)?.title
  if title and title isnt ''
    return title
  return
