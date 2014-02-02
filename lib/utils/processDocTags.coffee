###
# # Process Doc Tags
#
# Code from [`groc/lib/utils`][1]
#
# @copyright Ian MacLeod and groc contributors
#
# [1]: https://github.com/nevir/groc/blob/b626e45ebf/lib/utils.coffee
###

Q = require 'q'

DOC_TAGS = require '../docTags'
humanize = require './humanize'

TAG_REGEX = /(?:^|\s)@(\w+)(?:\s+(.*))?/
TAG_VALUE_REGEX = /^(?:"(.*)"|'(.*)'|\{(.*)\}|(.*))$/

###
# ## Parse Doc Tags
# @description Combine Array of doc tags to HTML string
# @param {Object} segment
# @param {[String]} segment.comments
# @return {Object} The processed segment
###
parseDocTagsForSegment = (segment) ->
  tags = []
  currTag = {
    name: 'description'
    value: ''
  }
  tags.push currTag
  tagSections = {}

  for line in segment.comments when line?
    if (match = line.match TAG_REGEX)?
      currTag = {
        name: match[1]
        value: match[2] || ''
      }
      tags.push currTag
    else
      currTag.value += "\n#{line}"

  for tag in tags
    tag.value = tag.value.replace /^\n|\n$/g, ''

    tagDefinition = DOC_TAGS[tag.name]

    unless tagDefinition?
      if tag.value.length is 0
        tagDefinition = 'defaultNoValue'
      else
        tagDefinition = 'defaultHasValue'

    if typeof tagDefinition is 'string'
      tagDefinition = DOC_TAGS[tagDefinition]

    tag.definition = tagDefinition
    tag.section = tagDefinition.section

    if tagDefinition.valuePrefix?
      tag.value = tag.value.replace ///#{tagDefinition.valuePrefix?}\s+///, ''

    if tagDefinition.parseValue?
      try
        tag.value = tagDefinition.parseValue tag.value
      catch e
    else if not /\n/.test tag.value
      tag.value = tag.value.match(TAG_VALUE_REGEX)[1..].join('')

    tagSections[tag.section] = [] unless tagSections[tag.section]?
    tagSections[tag.section].push tag

  segment.tags = tags
  segment.tagSections = tagSections
  return segment

###
# ## Markdown Doc Tags
# @description Transform each doc tag entry to markdown
# @param {Object} segment
# @param {Array} segment.tags List of doc tags
# @return {Object} The processed segment
###
markdownDocTagsForSegment = (segment) ->
  for tag in segment.tags
    if tag.definition.markdown?
      if 'string' == typeof tag.definition.markdown
        tag.markdown = tag.definition.markdown.replace /\{value\}/g, tag.value
      else
        try
          tag.markdown = tag.definition.markdown(tag.value)
        catch e
          tag.markdown = tag.value
    else
      if tag.value.length > 0
        tag.markdown = "#{tag.name} #{tag.value}"
      else
        tag.markdown = tag.name
  return segment

###
# ## Render Doc Tags
# @description Combine Array of doc tags to HTML string
# @param {Object} segment
# @param {Object} segment.tagSections
# @return {Object} The processed segment
###
renderDocTagsForSegment = (segment) ->
  sections = segment.tagSections
  output = []
  metaOutput = ''
  accessClasses = 'doc-section'

  accessClasses += " doc-section-#{tag.name}" for tag in sections.access if sections.access?

  segment.accessClasses = accessClasses

  firstPart = []
  firstPart.push tag.markdown for tag in sections.access if sections.access?
  firstPart.push tag.markdown for tag in sections.special if sections.special?
  firstPart.push tag.markdown for tag in sections.type if sections.type?

  metaOutput += "#{humanize.capitalize firstPart.join(' ')}"
  if sections.flags? or sections.metadata?
    secondPart = []
    secondPart.push tag.markdown for tag in sections.flags if sections.flags?
    secondPart.push tag.markdown for tag in sections.metadata if sections.metadata?
    metaOutput += " #{humanize.joinSentence secondPart}"

  output.push "<span class='doc-section-header'>#{metaOutput}</span>", "" if metaOutput isnt ''

  output.push "#{tag.markdown}", "" for tag in sections.description if sections.description?

  output.push "#{tag.markdown}", "" for tag in sections.todo if sections.todo?

  if sections.params?
    output.push 'Parameters:', ""
    for tag in sections.params
      output.push "#{tag.markdown}"
    output.push ""

  if sections.returns?
    returns = for tag in sections.returns
      humanize.capitalize(tag.markdown)

    output.push returns.join('<br/>**and** ')

  if sections.howto?
    for tag in sections.howto
      output.push "", "How-To:", "", humanize.gutterify(tag.markdown, 0)

  if sections.example?
    for tag in sections.example
      output.push "", "Example:", "", humanize.gutterify(tag.markdown, 4)

  segment.comments = output
  return segment

###
# ## Export Methods for Segment Arrays
###
module.exports =
  ###
  # @method Parse Doc Tags
  # @description Parses comments of segment for doc tags. Adds `tags` and
  #   `tagSections` to each segment.
  # @param {Array} segments `[{code, comments}]`
  # @return {Promise} Resolves when segment comments have been processed
  ###
  parseDocTags: (segments) ->
    deferred = Q.defer()

    try
      segments
      .filter (segment) ->
        TAG_REGEX.test segment.comments.join('\n')
      .forEach(parseDocTagsForSegment)

      deferred.resolve(segments)
    catch error
      deferred.reject(error)

    return deferred.promise

  ###
  # @method Markdown Doc Tags
  # @description Transform each doc tag entry to markdown
  # @param {Array} segments `[{code, comments, tags}]`
  # @return {Promise} Resolves when all tags have been processed
  ###
  markdownDocTags: (segments) ->
    deferred = Q.defer()

    try
      segments
      .filter((segment) -> segment.tags?)
      .forEach(markdownDocTagsForSegment)

      deferred.resolve(segments)
    catch error
      deferred.reject(error)

    return deferred.promise

  ###
  # @method Render Doc Tags
  # @description Combine Array of doc tags to HTML string
  # @param {Array} segments `[{code, comments, tags, tagSections}]`
  # @return {Promise} Resolves when all segments have been processed
  ###
  renderDocTags: (segments) ->
    deferred = Q.defer()

    try
      segments
      .filter((segment) -> segment.tagSections?)
      .forEach(renderDocTagsForSegment)

      deferred.resolve(segments)
    catch error
      deferred.reject(error)

    return deferred.promise

