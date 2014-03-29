###
# # Grock Solarized Side Menu
#
# @copyright 2014 Pascal Hertleif
# @license MIT
###

$ = Zepto or jQuery

###
# ## Convert List of Files to File Tree
# @param {Array} list Files in flat list
# @return {Object} Files in tree (by folders)
#
# @example
# ```js
# Schema(list) == [{
#   path: String,
#   originalName: String,
#   originalPath: String,
#   name: String,
#   lang: String,
#   toc: [Headline]
# }]
# ```
###
listToTree = (list) ->
  tree = {}

  for file in list
    path = file.path.split('/')
    fileDepth = path.length - 1
    cur = tree

    for part, depth in path
      if (cur[part]?.type isnt 'file') and (depth is fileDepth-1) and file.originalName.match(/index\.(js|coffee)/)
        cur[part] or= {}
        cur[part].path = file.path
        cur[part].originalName = file.originalName
        cur[part].originalPath = file.originalPath
        cur[part].name = file.name
        cur[part].title = part
        cur[part].type = 'file'
        cur[part].children or= {}
        break
      if depth is fileDepth
        cur[part] = file
        cur[part].type = 'file'
      else
        cur[part] or= name: part, type: 'folder'
        cur = cur[part].children or= {}

  return tree

###
# ## Convert TOC to Headline Tree
# @param {Array} toc List of Headlines
# @return {Array} Tree of Headlines
#
# @example
# ```js
# Schema(toc) == [{
#   level: Number,
#   title: String,
#   slug: String,
# }]
# ```
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
  $ul = $(ul)
  unless tree?
    console.warn 'No File Tree!'
    return $ul

  $.each tree, (fileName, node) ->
    $node = $("""<li class="#{node.type}"/>""")
    if node.type is 'file'
      currentFile = node is metaInfo.currentFile
      $node.append """<a class="file#{if currentFile then ' selected' else ''}" href="#{metaInfo.relativeRoot}#{node.path}" title="#{node.originalName or node.name}">#{node.title or node.originalName or node.name}</a>"""
    else # folder
      $node.append """<span class="folder">#{node.name}</span>"""

    if node.children?
      $children = $('<ol class="children"/>')
      $node.append buildFileTree node.children, $children, metaInfo

    if node.originalName?.match /^readme\.(md|txt|rst)/i
      position = 'prepend'
    else
      position = 'append'
    $ul[position] $node
    return

  return $ul


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
    $node = $("""<li class="headline"/>""")
    $node.append """<a class="label" href="##{node.slug}">#{node.title}</a>"""

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
  # @method search
  # @param {jQuery} tree
  # @param {String} value Search query
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
      if ($item.text().toLowerCase().indexOf(value) > -1) or ($item.attr('href').toLowerCase().indexOf(value) > -1)
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
    return

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


