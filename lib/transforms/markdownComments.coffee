###
# # Render Markdown Comments
#
# This will render a file's segment's comments using markdown and add a list of
# headlines to `file.exta.toc`.
###

Buffer = require('buffer').Buffer
map = require 'map-stream'

hljs = require 'highlight.js'
marked = require 'marked'

marked.setOptions
  # Highlight code in comments, e.g. examples
  highlight: (code, lang) ->
    if lang
      try
        return hljs.highlight(lang, code, true).value
      catch e
        return code
    else
      try
        return hljs.highlightAuto(code).value
      catch e
        return code
      
    return code

# Instantiate custom renderer, will be used to collect headlines for TOC
renderer = new marked.Renderer()

# Add support for checkbox list items
renderer.listitem = (text) ->
  text = text.replace /^\[x\] /, '<input type="checkbox" checked disabled/> '
  text = text.replace /^\[ \] /, '<input type="checkbox" disabled/> '
  return "<li>#{text}</li>\n"

###
# @method Set Heading Renderer
# @param {marked.Renderer} renderer
# @param {Array} toc Array of headlines, for table of contents
# @return {String} The rendered headline
###
setHeadingRenderer = (renderer, toc) ->
  renderer.heading = (text, level) ->
    slug = text.toLowerCase().replace(/[^\w]+/g, '-')
    toc.push level: level, slug: slug, title: text

    return """<h#{level} id="#{slug}"><a href="##{slug}" class="anchor"></a>#{text}</h#{level}>"""

module.exports = (options) ->
  # Annotate an array of segments by running their comments through
  # [marked](https://github.com/chjj/marked).
  modifyFile = (file, cb) ->
    file.extra or= {}
    toc = file.extra.toc or= []

    # No comment(s)
    cb(null, file) unless file.segments?.length

    for s in file.segments
      continue unless s.comments?.length

      setHeadingRenderer(renderer, toc)
      s.comments = marked s.comments.join('\n'), renderer: renderer

    cb(null, file)
    return

  return map(modifyFile)
