###
# # Grock Solarized Side Menu
#
# @copyright 2014 Pascal Hertleif
# @license MIT
###

###
# ## Table of Contents
#
# Schema:
# ```javascript
# var File, Folder, Headline, index;
# Headline = {
#   type: "heading",
#   depth: Number,
#   data: {
#     level: Number,
#     title: String,
#     slug: String,
#     isFileHeader: Boolean
#   },
#   children: [Headline]
# };
# File = {
#   type: "file",
#   depth: Number,
#   data: {
#     title: String,
#     pageTitle: String,
#     sourcePath: String,
#     projectPath: String,
#     targetPath: String,
#     language: {
#       nameMatchers: [String],
#       commentsOnly: Boolean,
#       name: String
#     },
#     firstHeader: Headline
#   },
#   outline: [Headline],
#   children: [(File||Folder)]
# };
# Folder = {
#   type: "folder",
#   data: {
#     path: String,
#     title: String
#   },
#   depth: Number,
#   children: [(File||Folder)]
# };
# index = [(File||Folder)];
# ```
###
$ = Zepto or jQuery

###
## Build File Tree Recursively
@param {Array} tree List of file or folder Objects
@param {jQuery} ul DOM node of list to append this tree to
@param {Object} metaInfo Project information
@return {jQuery} The ul element
###
buildFileTree = (tree, ul, metaInfo) ->
  ul = $(ul)
  unless tree?.length
    console.warn 'No File Tree!'
    return ul

  $.each tree, (index, node) ->
    $node = $("""<li class="#{node.type}"/>""")
    if node.type is 'file'
      currentFile = metaInfo.documentPath is node.data.targetPath
      if currentFile
        console.warn 'duplicate currentFile' if metaInfo.currentFileNode
        metaInfo.currentFileNode = node

      $node.append """<a class="label#{if currentFile then ' selected' else ''}" href="#{metaInfo.relativeRoot}#{node.data.targetPath}.html" title="#{node.data.projectPath}"><span class="text">#{node.data.title}</span></a>"""
    else
      $node.append """<a class="label" data-path="#{node.data.path}" href="#"><span class="text">#{node.data.title}</span></a>"""

    if node.children?.length > 0
      $children = $('<ol class="children"/>')
      $node.append buildFileTree node.children, $children, metaInfo

    ul.append $node
    return

  return ul


###
## Build Headlines Tree Recursively
@param {Object} tree Tree of headlines
@param {jQuery} ul DOM node of list to append this tree to
@param {Object} metaInfo Project information
@return {jQuery} The ul element
###
buildHeadlinesTree = (tree, ul, metaInfo) ->
  ul = $(ul)
  unless tree?.length
    console.warn 'no tree', tree
    return ul

  $.each tree, (index, node) ->
    $node = $("""<li class="#{node.type}"/>""")
    $node.append """<a class="label" href="##{node.data.slug}"><span class="text">#{node.data.title}</span></a>"""

    if node.children?.length > 0
      $children = $('<ol class="children"/>')
      $node.append buildHeadlinesTree node.children, $children, metaInfo

    ul.append $node
    return

  return ul

###
## Create Navigation Element
@param {Object} metaInfo Project information
@return {jQuery} Navigation element
###
createNav = (metaInfo) ->
  $nav = $ """
    <aside id="side-menu">
      <nav id="headlines">
        <details>
          <summary>This File</summary>
          <ul class="tools">
            <li class="search">
              <input id="search-headlines" type="search" autocomplete="off" placeholder="Search"/>
            </li>
          </ul>
          <ol class="tree" id="headline-tree"></ol>
        </details>
      </nav>
      <nav id="files">
        <details open>
          <summary>Files</summary>
          <ul class="tools">
            <li class="search">
              <input id="search-files" type="search" autocomplete="off" placeholder="Search"/>
            </li>
          </ul>
          <ol class="tree" id="file-tree"></ol>
        </details>
      </nav>
    </aside>
  """

  return $nav

###
## Add Button to Toggle Side Menu Visibility
@param {jQuery} $container The element the button should be prepended to
@param {jQuery} $nav The navigation element; class 'open' will be toggled
@return {jQuery} $container element
###
createMenuToggle = ($container, $nav) ->
  $button = $ """<button type="button" class="toggle-menu">
    Menu
  </button>"""

  $button.on 'click', (event) ->
    event.preventDefault()
    $nav.toggleClass 'open'

  $container.prepend $button

  return $container

###
## Search Tree
@param {jQuery} $tree The tree element to be searched
@param {jQuery} $search The search input field
###
searchTree = ($tree, $search) ->
  ###
  @method throttle
  @param {Function} fn Callback
  @param {Number} timeout
  ###
  throttle = do ->
    timer: null
    (fn, timeout=100) ->
      window.clearTimeout timer if timer
      timer = window.setTimeout (->
        timer = null
        fn?()
      ), timeout

  ###
  @method search
  @param {jQuery} tree
  @param {String} value Search query
  ###
  search = ($tree, value) ->
    value = value.trim().toLowerCase()
    $tree.find('.matched').removeClass 'matched'

    if value is ""
      console.log 'stop searching'
      $tree.removeClass 'searching'
      return

    $tree.addClass 'searching'
    $tree.find('a').each (index, item) ->
      $item = $(item)
      if $item.text().toLowerCase().indexOf(value) > -1 or $item.attr('href').toLowerCase().indexOf(value) > -1
        $item.addClass 'matched'
        # show folders above matched item
        $item.parents('li').children('.label').addClass 'matched'
      return

  value = null
  $search.on 'keyup search', (event) ->
    newVal = event.target.value
    return if newVal is value
    return if newVal < 2 and newVal isnt ""
    value = newVal
    throttle ->
      search($tree, value)

  # ESC
  $search.on 'keydown', (event) ->
    if event.keyCode == 27 # Esc
      if $search.val().trim() is ''
        $search.blur()
      else
        $search.val ''

###
## Build Navigation
@param {Array} fileTree List of Files
@param {Object} metaInfo Project information
@return {jQuery} The nav element
###
buildNav = (fileTree, metaInfo) ->
  return $('') unless fileTree
  $nav = createNav(metaInfo)

  # Build file tree
  #
  # This also sets `metaInfo.currentFileNode`.
  buildFileTree fileTree, $nav.find('#file-tree'), metaInfo
  searchTree $nav.find('#file-tree'), $nav.find('#search-files')

  # Build headlines tree
  if file = metaInfo.currentFileNode
    headlineTree = null
    if file.data.firstHeader
      headlineTree = [file.data.firstHeader]
    else
      headlineTree = file.outline

    buildHeadlinesTree headlineTree, $nav.find('#headline-tree'), metaInfo
    searchTree $nav.find('#headline-tree'), $nav.find('#search-headlines')
  return $nav

$ ->
  metaInfo =
    relativeRoot: $('meta[name="groc-relative-root"]').attr('content')
    githubURL:    $('meta[name="groc-github-url"]').attr('content')
    documentPath: $('meta[name="groc-document-path"]').attr('content')
    projectPath:  $('meta[name="groc-project-path"]').attr('content')

  $nav = buildNav files, metaInfo
  $nav.prependTo $('body')

  createMenuToggle $('#meta'), $nav


