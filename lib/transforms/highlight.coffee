###
# # Highlight Code
#
# Uses [`highlights`](https://github.com/atom/highlights).
###
path = require 'path'
Highlights = require 'highlights'

Buffer = require('buffer').Buffer
map = require('event-stream').map

highlighter = new Highlights()
###
# @method Highlight a Segment of Code
# @param {String} code String of code to be highlighted
# @param {String} [lang='AUTO'] Language of the code, will default to auto
#   detection
# @return {String} Highlighted code (HTML)
###
highlightSegment = (code, lang='AUTO') ->
  highlighter.highlightSync
    fileContents: code
    scopeName: "source.#{lang}"

module.exports = (options) ->
  modifyFile = (file, cb) ->
    lang = file.extra?.lang or {}

    # Skip unnecessary highlighting (e.g. for Markdown files)
    return cb(null, file) if lang.commentsOnly

    hlLang = path.extname(file.path).replace(/^\./, '')

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
