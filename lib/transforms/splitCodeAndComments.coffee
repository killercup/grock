###
# # Split Code and Comments
###

path = require('path')
Buffer = require('buffer').Buffer
map = require('event-stream').map
_ = require('lodash')

Highlights = require('highlights')

class Tokenizer extends Highlights
  prepare: (vinylFile) ->
    @loadGrammarsSync()

    filePath = vinylFile.path
    fileContents = vinylFile.contents.toString('utf8')
    fileExt = path.extname(vinylFile.path).replace(/^\./, '')
    scopeName = "source.#{fileExt}"

    grammar = @registry.grammarForScopeName(scopeName)
    grammar ?= @registry.selectGrammar(filePath, fileContents)

    # Lines of tokens: `[{scopes, values}]`
    lineTokens = grammar.tokenizeLines(fileContents)

    # Remove trailing newline
    if lineTokens.length > 0
      lastLineTokens = lineTokens[lineTokens.length - 1]
      if lastLineTokens.length is 1 and lastLineTokens[0].value is ''
        lineTokens.pop()

    return lineTokens

  seperate: (vinylFile) ->
    # lineTokens :: [[{scopes :: [String], value :: String}]]
    lineTokens = @prepare(vinylFile)
    # segments :: [{code :: [String], comments :: [String]}]
    segments = []

    isWhitespace = (s) -> /^punctuation\.whitespace/.test(s)
    isCommentSign = (s) -> /^punctuation\.definition\.comment/.test(s)
    isCommentLine = (s) -> /^comment\.line/.test(s)
    isCommentBlock = (s) -> /^comment\.block/.test(s)
    isComment = (scope) =>
      isCommentLine(scope) or isCommentBlock(scope)

    trimMultilineCommentLine = do ->
      lang = vinylFile.extra?.lang
      if _.isArray lang?.multiLineComment
        seps = []
        lang.multiLineComment.forEach (c, index) ->
          if (index % 3) is 1
            seps.push c

      (str) ->
        str = str.trim()
        return str unless lang

        for sep in seps
          if str[0] is sep
            ###
            # Cut off block indicator and space, e.g.
            #
            # ```js
            # /**
            #  * Sup?
            #  *\/
            # ```
            #
            # becomes `Sup?`
            ###
            str = str.substr(2)
            break
        return str

    checkIfLineIsComment = (tokens) ->
      for {scopes, value} in tokens
        if _.any(scopes, isWhitespace) or value.trim().length is 0
          continue
        else if _.any(scopes, isCommentLine) or _.any(scopes, isCommentBlock)
          return true
        else
          break
      return false

    currentSegment = code: '', comments: []
    processingComments = true

    for tokens, index in lineTokens
      if checkIfLineIsComment(tokens)
        # console.log "line #{index+1} is a comment"
        # new segment when a new comments block starts
        if not processingComments
          # console.log "new block"
          segments.push(currentSegment)
          currentSegment = code: '', comments: []
        processingComments = true

        for {scopes, value} in tokens
          continue if _.any(scopes, isCommentSign)
          val = trimMultilineCommentLine(value)
          continue if val.length is 0
          currentSegment.comments.push val
      else
        # console.log "line #{index+1} is code", tokens
        processingComments = false
        scopeStack = []

        html = ''
        for {scopes, value} in tokens
          value = ' ' unless value
          html = @updateScopeStack(scopeStack, scopes, html)
          html += "<span>#{@escapeString(value)}</span>"
        html = @popScope(scopeStack, html) while scopeStack.length > 0
        currentSegment.code += html+"\n"

    segments.push(currentSegment)

    # console.log '--- result ---'
    # console.log JSON.stringify segments, null, 2
    return segments

module.exports = (options) ->
  seperator = new Tokenizer()

  modifyFile = (file, cb) ->
    lang = file.extra?.lang
    if lang?.commentsOnly
      file.segments = [{
        code: '', comments: file.contents.toString('utf8').split('\n')
      }]
    else
      try
        str = file.contents.toString('utf8')
        file.segments = seperator.seperate(file)
      catch e
        err = new Error("seperator: Error seperating code and comments #{e}")
        err.file = file.relative
        return cb(err)

    return cb(null, file)

  return map(modifyFile)
