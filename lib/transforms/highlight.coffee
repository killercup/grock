###
# # Highlight Code
#
# Uses [`highlight.js`](http://highlightjs.org/).
###
path = require 'path'
hljs = require 'highlight.js'

Buffer = require('buffer').Buffer
map = require('event-stream').map

###
# @method Highlight a Segment of Code
# @param {String} code String of code to be highlighted
# @param {String} [lang='AUTO'] Language of the code, will default to auto
#   detection
# @return {String} Highlighted code (HTML)
###
highlightSegment = (code, lang='AUTO') ->
  if lang and (lang isnt 'AUTO')
    value = hljs.highlight(lang, code, true).value
  else
    value = hljs.highlightAuto(code).value
  value = value.replace /^[\n]+/, ''

module.exports = (options) ->
  modifyFile = (file, cb) ->
    lang = file.extra?.lang or {}

    # Skip unnecessary highlighting (e.g. for Markdown files)
    return cb(null, file) if lang.commentsOnly

    hlLang = lang.highlightJS or lang.pygmentsLexer

    try
      if file.segments
        for segment in file.segments
          segment.code = highlightSegment(segment.code.join('\n'), hlLang)
      else
        # Highlight complete file content when file is not split into segments
        str = file.contents.toString('utf8')
        file.contents = new Buffer highlightSegment(str, hlLang)
        file.path = file.path + ".html"
    catch e
      err = new Error("highlight: Error highlighting stuff #{e}")
      err.file = file.relative
      return cb(err)

    return cb(null, file)

  return map(modifyFile)
