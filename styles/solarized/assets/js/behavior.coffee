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
#   level: Number,
#   title: String,
#   slug: String,
# };
# File = {
#   path: String,
#   originalName: String,
#   originalPath: String,
#   name: String,
#   lang: String,
#   toc: [Headline]
# };
# files = [File];
# ```
###
$ = Zepto or jQuery

###
# ## Convert List of Files to File Tree
# @param {Array} list Files in flat list
# @return {Object} Files in tree (by folders)
###
listToTree = (list) ->
  tree = {}

  for file in list
    path = file.path.split('/')
    fileDepth = path.length - 1
    cur = tree

    for pathSegment, depth in path
      if (depth is fileDepth-1) and file.originalName.match /index\.(js|coffee)/
        cur[pathSegment].path = file.path
        cur[pathSegment].originalName = file.originalName
        cur[pathSegment].originalPath = file.originalPath
        cur[pathSegment].name = file.name
        cur[pathSegment].title = pathSegment
        cur[pathSegment].type = 'file'
        cur[pathSegment].children or= {}
        break
      if depth is fileDepth
        cur[pathSegment] = file
        cur[pathSegment].type = 'file'
      else
        cur[pathSegment] or= name: pathSegment, type: 'folder'
        cur = cur[pathSegment].children or= {}

  return tree

###
# ## Convert TOC to Headline Tree
# @param {Array} toc List of Headlines
# @return {Array} Tree of Headlines
###
tocToTree = (toc) ->
  headlines = []
  last = {}

  for headline in toc
    level = headline.level or= 1
    if last[level - 1]
      last[level - 1].children or= []
      last[level - 1].children.push headline
    else
      headlines.push headline
    last[level] = headline

  return headlines


###
# ## Build File Tree Recursively
# @param {Array} tree List of file or folder Objects
# @param {jQuery} ul DOM node of list to append this tree to
# @param {Object} metaInfo Project information
# @return {jQuery} The ul element
###
buildFileTree = (tree, ul, metaInfo) ->
  ul = $(ul)
  unless tree?
    console.warn 'No File Tree!'
    return ul

  $.each tree, (fileName, node) ->
    $node = $("""<li class="#{node.type}"/>""")
    if node.type is 'file'
      currentFile = node is metaInfo.currentFile
      $node.append """<a class="label#{if currentFile then ' selected' else ''}" href="#{metaInfo.relativeRoot}#{node.path}" title="#{node.originalName or node.name}"><span class="text">#{node.title or node.originalName or node.name}</span></a>"""
    else
      $node.append """<a class="label"><span class="text">#{node.name}</span></a>"""

    if node.children?
      $children = $('<ol class="children"/>')
      $node.append buildFileTree node.children, $children, metaInfo

    ul.append $node
    return

  return ul


###
# ## Build Headlines Tree Recursively
# @param {Object} tree Tree of headlines
# @param {jQuery} ul DOM node of list to append this tree to
# @param {Object} metaInfo Project information
# @return {jQuery} The ul element
###
buildHeadlinesTree = (tree, ul, metaInfo) ->
  ul = $(ul)
  unless tree?.length
    return ul

  $.each tree, (index, node) ->
    $node = $("""<li class="#{node.type}"/>""")
    $node.append """<a class="label" href="##{node.slug}"><span class="text">#{node.title}</span></a>"""

    if node.children?.length > 0
      $children = $('<ol class="children"/>')
      $node.append buildHeadlinesTree node.children, $children, metaInfo

    ul.append $node
    return

  return ul

###
# ## Create Navigation Element
# @param {Object} metaInfo Project information
# @return {jQuery} Navigation element
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
# ## Add Button to Toggle Side Menu Visibility
# @param {jQuery} $container The element the button should be prepended to
# @param {jQuery} $nav The navigation element; class 'open' will be toggled
# @return {jQuery} $container element
###
createMenuToggle = ($container, $nav) ->
  $button = $ """<button type="button" class="toggle-menu">
    Menu
  </button>"""

  $button.on 'click', (event) ->
    event.preventDefault()
    $nav.toggleClass('open')

  # $('#file-area').on 'click', (event) ->
  #   return if $(event.target).hasClass('toggle-menu')
  #   if $nav.hasClass('open')
  #     event.preventDefault()
  #     $nav.removeClass('open')
  #   return

  $container.prepend $button

  return $container

###
# ## Search Tree
# @param {jQuery} $tree The tree element to be searched
# @param {jQuery} $search The search input field
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
# ## Build Navigation
# @param {Array} files List of Files
# @param {Object} metaInfo Project information
# @return {jQuery} The nav element
###
buildNav = (files, metaInfo) ->
  return $('') unless files
  $nav = createNav(metaInfo)

  # Find current file
  for file in files
    if file.originalPath is metaInfo.documentPath
      metaInfo.currentFile = file
      break

  # Build file tree
  fileTree = listToTree(files)
  buildFileTree(fileTree, $nav.find('#file-tree'), metaInfo)
  searchTree($nav.find('#file-tree'), $nav.find('#search-files'))

  # Build headlines tree
  if metaInfo.currentFile
    headlineTree = tocToTree(metaInfo.currentFile.toc or [])

    buildHeadlinesTree(headlineTree, $nav.find('#headline-tree'), metaInfo)
    searchTree($nav.find('#headline-tree'), $nav.find('#search-headlines'))

  return $nav

$ ->
  metaInfo =
    relativeRoot: $('meta[name="groc-relative-root"]').attr('content')
    githubURL:    $('meta[name="groc-github-url"]').attr('content')
    documentPath: $('meta[name="groc-document-path"]').attr('content')
    projectPath:  $('meta[name="groc-project-path"]').attr('content')

  $nav = buildNav window.files, metaInfo
  $nav.prependTo $('body')

  createMenuToggle $('#meta'), $nav

  window.listToTree = listToTree
  window.tocToTree = tocToTree


