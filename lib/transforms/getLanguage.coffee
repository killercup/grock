###
# # Get File Language
###

path = require 'path'
Buffer = require('buffer').Buffer
map = require 'map-stream'

_ = require 'lodash'

regexpEscape = require('../utils/regexpEscape')
LANGUAGES = require '../languages'

_languageDetectionCache = []
do ->
  for name, language of LANGUAGES
    language.name = name

    for matcher in language.nameMatchers
      # If the matcher is a string, we assume that it's a file extension.
      # Stick it in a regex:
      matcher = ///#{regexpEscape matcher}$/// if _.isString matcher

      _languageDetectionCache.push [matcher, language]

fileextToLanguage = (filePath='') ->
  baseName = path.basename filePath

  for pair in _languageDetectionCache
    return pair[1] if baseName.match pair[0]

module.exports = (options) ->
  modifyFile = (file, cb) ->
    file.extra or= {}
    file.extra.lang = fileextToLanguage(file.path)
    
    cb(null, file)
    return

  return map(modifyFile)
