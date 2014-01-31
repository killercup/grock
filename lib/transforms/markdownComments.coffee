###
# # Render Markdown Comments
#
# Uses [`marked`](https://github.com/chjj/marked).
#
# This will render a file's segment's comments using markdown and add a list of
# headlines to `file.exta.toc`.
###

Buffer = require('buffer').Buffer
map = require('event-stream').map

hljs = require 'highlight.js'
marked = require 'marked'

###
# ## Options
#
# Highlight code in comments, e.g. examples
###
marked.setOptions
  highlight: (code, lang) ->
    if lang
      try
        code = hljs.highlight(lang, code, true).value
      catch e
    else
      try
        code = hljs.highlightAuto(code).value
      catch e
      
    return code

###
# ## Custom Renderer
###
renderer = new marked.Renderer()

###
# @method Render TODO Lists
# @param {String} text The input text of the list item
# @return {String} List item (possibly with checkboxes)
###
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
    # Trim HTML Tags from heading
    heading = text.replace(/<(?:.|\n)*?>/gm, '')
    # Remove spaces to form slug
    slug = heading.toLowerCase().replace(/[^\w]+/g, '-')

    toc.push level: level, slug: slug, title: heading

    return """<h#{level} id="#{slug}"><a href="##{slug}" class="anchor"></a>#{text}</h#{level}>"""

module.exports = (options) ->
  # Annotate an array of segments by running their comments through
  # [marked](https://github.com/chjj/marked).
  modifyFile = (file, cb) ->
    file.extra or= {}
    toc = file.extra.toc or= []

    # Skip unnecessary Markdown rendering (e.g. for JSON files)
    lang = file.extra.lang or {}
    return cb(null, file) if lang.codeOnly

    # No comment(s)
    return cb(null, file) unless file.segments?.length

    for s in file.segments
      continue unless s.comments?.length

      setHeadingRenderer(renderer, toc)
      s.comments = marked s.comments.join('\n'), renderer: renderer

    cb(null, file)

  return map(modifyFile)
