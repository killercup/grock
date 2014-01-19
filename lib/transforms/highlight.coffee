path = require 'path'
hljs = require 'highlight.js'

gutil = require 'gulp-util'
map = require 'map-stream'
Buffer = require('buffer').Buffer

###
# @method Highlight a Segment of Code
# @param {String} code String of code to be highlighted
# @param {String} [lang='AUTO'] Language of the code, will default to auto
#   detection
# @return {String} Highlighted code (HTML)
###
highlightSegment = (code, lang='AUTO') ->
  if lang isnt 'AUTO'
    hljs.highlight(lang, code, true).value
  else
    hljs.highlightAuto(code).value

module.exports = (options) ->
  modifyFile = (file, cb) ->
    lang = file.extra?.lang or {}
    hlLang = lang.highlightJS or lang.pygmentsLexer

    try
      if file.segments
        for segment in file.segments
          segment.code = highlightSegment(segment.code.join('\n'), hlLang)
      else
        str = file.contents.toString('utf8')
        file.contents = new Buffer highlightSegment(str, hlLang)
        file.path = gutil.replaceExtension(file.path, ".html")
    catch e
      return cb(new Error("highlight: Error highlighting stuff #{e}"))

    return cb(null, file)

  return map(modifyFile)
