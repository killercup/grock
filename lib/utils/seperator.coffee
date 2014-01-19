###
# # Seperate Code and Comments into Segments
#
# Code from <https://github.com/nevir/groc/blob/b626e45ebf/lib/utils.coffee>
###

_ = require 'lodash'

module.exports =
  regexpEscape: require('./regexpEscape')

  # Split source code into segments (comment + code pairs)
  splitSource: (data, language, options={}) ->
    lines = data.split /\r?\n/

    # Always strip shebangs - but don't shift it off the array to
    # avoid the perf hit of walking the array to update indices.
    lines[0] = '' if lines[0][0..1] is '#!'

    # Special case: If the language is comments-only, we can skip pygments
    return [new @Segment [], lines] if language.commentsOnly

    # Special case: If the language is code-only, we can shorten the process
    return [new @Segment lines, []] if language.codeOnly

    segments = []
    currSegment = new @Segment

    # Enforced whitespace after the comment token
    whitespaceMatch = if options.requireWhitespaceAfterToken then '\\s' else '\\s?'

    if language.singleLineComment?
      singleLines = @regexpEscape(language.singleLineComment).join '|'
      aSingleLine = ///
        ^\s*                        # Start a line and skip all indention.
        (?:#{singleLines})          # Match the single-line start but don't capture this group.
        (?:                         # Also don't capture this group …
          #{whitespaceMatch}        # … possibly starting with a whitespace, but
          (.*)                      # … capture anything else in this …
        )?                          # … optional group …
        $                           # … up to the EOL.
      ///


    if language.multiLineComment?
      mlc = language.multiLineComment

      unless (mlc.length % 3) is 0
        throw new Error('Multi-line block-comment definitions must be a list of 3-tuples')

      blockStarts = _.select mlc, (v, i) -> i % 3 == 0
      blockLines  = _.select mlc, (v, i) -> i % 3 == 1
      blockEnds   = _.select mlc, (v, i) -> i % 3 == 2

      # This flag indicates if the end-mark of block-comments (the `blockEnds`
      # list above) must correspond to the initial block-mark (the `blockStarts`
      # above).  If this flag is missing it defaults to `true`.  The main idea
      # is to embed sample block-comments with syntax A in another block-comment
      # with syntax B. This useful in handlebar's mixed syntax or other language
      # combinations like html+php, which are supported by `pygmentize`.
      strictMultiLineEnd = language.strictMultiLineEnd ? true

      # This map is used to lookup corresponding line- and end-marks.
      blockComments = {}
      for v, i in blockStarts
        blockComments[v] =
          linemark: blockLines[i]
          endmark : blockEnds[i]

      blockStarts = @regexpEscape(blockStarts).join '|'
      blockLines  = @regexpEscape(blockLines).join '|'
      blockEnds   = @regexpEscape(blockEnds).join '|'

      # No need to match for any particular real content in `aBlockStart`, as
      # either `aBlockLine`, `aBlockEnd` or the `inBlock` catch-all fallback
      # handles the real content, in the implementation below.
      aBlockStart = ///
        ^(\s*)                      # Start a line and capture indention, used to reverse indent catch-all fallback lines.
        (#{blockStarts})            # Capture the start-mark, to check the if line- and end-marks correspond, …
        (#{blockLines})?            # … possibly followed by a line, captured to check if its corresponding to the start,
        (?:#{whitespaceMatch}|$)    # … and finished by whitespace OR the EOL.
      ///

      aBlockLine = ///
        ^\s*                        # Start a line and skip all indention.
        (#{blockLines})             # Capture the line-mark to check if it corresponds to the start-mark, …
        (#{whitespaceMatch})        # … possibly followed by whitespace,
        (.*)$                       # … and collect all up to the line end.
      ///

      aBlockEnd = ///
        (#{blockEnds})              # Capture the end-mark to check if it corresponds to the line start,
        (.*)?$                      # … and collect all up to the line end.
      ///

      ###
      # A special case used to capture empty block-comment lines, like the one
      # below this line …
      #
      # … and above this line.
      ###
      aEmptyLine = ///^\s*(?:#{blockLines})$///

    if language.ignorePrefix?
      {ignorePrefix} = language

    if language.foldPrefix?
      {foldPrefix} = language

    if (ignorePrefix? or foldPrefix?) and (singleLines? or blockStarts?)
      stripMarks = []
      stripMarks.push ignorePrefix if ignorePrefix?
      stripMarks.push foldPrefix if foldPrefix?
      stripMarks = @regexpEscape(stripMarks).join '|'

      # A dirty lap-dance performed here …
      singleStrip = ///
        (                           # Capture this group:
          (?:#{singleLines})        #   The comment marker(s) to keep …
          #{whitespaceMatch}        #   … plus whitespace
        )
        (?:#{stripMarks})           # The marker(s) to strip from result
      /// if singleLines?

      # … and the corresponding gang-bang here. 8-)
      blockStrip = ///
        (                           # Capture this group:
          (?:#{blockStarts})        #   The comment marker(s) to keep …
          (?:#{blockLines})?        #   … optionally plus one more mark
          #{whitespaceMatch}        #   … plus whitespace
        )
        (?:#{stripMarks})           # The marker(s) to strip from result
      /// if blockStarts?

    inBlock   = false
    inFolded  = false
    inIgnored = false

    # Variables used in temporary assignments have been collected here for
    # documentation purposes only.
    blockline = null
    blockmark = null
    linemark  = null
    space     = null
    endmark   = null
    indention = null
    comment   = null
    code      = null

    for line in lines

      # Match that line to the language's block-comment syntax, if it exists
      if aBlockStart? and not inBlock and (match = line.match aBlockStart)?
        inBlock = true

        # Reusing `match` as a placeholder.
        [match, indention, blockmark, linemark] = match

        # Strip the block-comments start, preserving any inline stuff.
        # We don't touch the `line` itself, as we still need it.
        blockline = line.replace aBlockStart, ''

        # If we found a `linemark`, prepend it (back) to the `blockline`, if it
        # does not correspond to the initial `blockmark`.
        if linemark? and blockComments[blockmark].linemark isnt linemark
          blockline = "#{linemark}#{blockline}"

        # Check if this block-comment is collapsible.
        if foldPrefix? and blockline.indexOf(foldPrefix) is 0

          # We always start a new segment if the current one is not empty or
          # already folded.
          if inFolded or currSegment.code.length > 0
            segments.push currSegment
            currSegment   = new @Segment

          ### ^ collapsing block-comments:
          # In block-comments only `aBlockStart` may initiate the collapsing.
          # This comment utilizes this syntax, by starting the comment with `^`.
          ###
          inFolded  = true

          # Let's strip the “^” character from our original line, for later use.
          line = line.replace blockStrip, '$1'
          # Also strip it from our `blockline`.
          blockline = blockline[foldPrefix.length...]

        # Check if this block-comment stays embedded in the code.
        else if ignorePrefix? and blockline.indexOf(ignorePrefix) is 0
          ### } embedded block-comments:
          # In block-comments only `aBlockStart` may initiate the embedding.
          # This comment utilizes this syntax, by starting the comment with `}`.
          ###
          inIgnored = true

          # Let's strip the “}” character from our original line, for later use.
          line = line.replace blockStrip, '$1'
          # Also strip it from our `blockline`.
          blockline = blockline[ignorePrefix.length...]

        # Block-comments are an important tool to structure code into larger
        # segments, therefore we always start a new segment if the current one
        # is not empty.
        else if currSegment.code.length > 0
          segments.push currSegment
          currSegment   = new @Segment
          inFolded      = false

      # This flag is triggered above.
      if inBlock

        # Catch all lines, unless there is a `blockline` from above.
        blockline = line unless blockline?

        # Match a block-comment's end, even when `inFolded or inIgnored` flags
        # are true …
        if (match = blockline.match aBlockEnd)?

          # Reusing `match` as a placeholder.
          [match, endmark, code] = match

          # The `endmark` must correspond to the `blockmark`'s.
          if not strictMultiLineEnd or blockComments[blockmark].endmark is endmark

            ### Ensure to leave the block-comment, especially single-lines like this one. ###
            inBlock = false

            blockline = blockline.replace aBlockEnd, '' unless (inFolded or inIgnored)

        # Match a block-comment's line, when `inFolded or inIgnored` are false.
        if not (inFolded or inIgnored) and (match = blockline.match aBlockLine)?

          # Reusing `match` as a placeholder.
          [match, linemark, space, comment] = match

          # If we found a `linemark`, prepend it (back) to the `comment`,
          # if it does not correspond to the initial `blockmark`.
          if linemark? and blockComments[blockmark].linemark isnt linemark
            comment = "#{linemark}#{space ? ''}#{comment}"

          blockline = comment

        if inIgnored
          currSegment.code.push line

          # Make sure that the next cycle starts fresh,
          # if we are going to leave the block.
          inIgnored = false if not inBlock

        else

          if inFolded

            # If the foldMarker is empty assign `blockline` to `foldMarker` …
            if currSegment.foldMarker is ''
              currSegment.foldMarker = line

            # … and collect the `blockline` as code.
            currSegment.code.push line

          else

            # The previous cycle contained code, so lets start a new segment.
            if currSegment.code.length > 0
              segments.push currSegment
              currSegment = new @Segment

            # A special case as described in the initialization of `aEmptyLine`.
            if aEmptyLine.test line
              currSegment.comments.push ""

            else
              ###
              Collect all but empty start- and end-block-comment lines, hence
              single-line block-comments simultaneous matching `aBlockStart`
              and `aBlockEnd` have a false `inBlock` flag at this point, are
              included.
              ###
              if not /^\s*$/.test(blockline) or (inBlock and not aBlockStart.test line)
                # Strip leading `indention` from block-comment like the one above
                # to align their content with the initial blockmark.
                if indention? and indention isnt '' and not aBlockLine.test line
                  blockline = blockline.replace ///^#{indention}///, ''

                currSegment.comments.push blockline

              # The `code` may occure immediatly after a block-comment end.
              if code?
                currSegment.code.push code unless inBlock # fool-proof ?
                code = null

        # Make sure the next cycle starts fresh.
        blockline = null

      # Match that line to the language's single line comment syntax.
      #
      # However, we treat all comments beginning with } as inline code commentary
      # and comments starting with ^ cause that comment and the following code
      # block to start folded.
      else if (match = line.match aSingleLine)?

        # Uses `match` as a placeholder.
        [match, comment] = match

        if comment? and comment isnt ''

          # } For example, this comment should be treated as part of our code.
          # } Achieved by prefixing the comment's content with “}”
          if ignorePrefix? and comment.indexOf(ignorePrefix) is 0

            # } Hint: never start a new segment here, these comments are code !
            # } If we would do so the segments look visually not so appealing in
            # } the narrowed single-column-view, and we can not embed a series
            # } of comments like these here.

            # Let's strip the “}” character from our documentation
            currSegment.code.push line.replace singleStrip, '$1'

          else

            # The previous cycle contained code, so lets start a new segment
            # and stop any folding.
            if currSegment.code.length > 0
              segments.push currSegment
              currSegment   = new @Segment
              inFolded      = false

            # It's always a good idea to put a comment before folded content
            # like this one here, because folded comments always have their
            # own code-segment in their current implementation (see above).
            # Without a leading comment, the folded code's segment would just
            # follow the above's code segment, which looks visually not so
            # appealing in the narrowed single-column-view.
            #
            # TODO: _Alternative (a)_: Improve folded comments to not start a new segment, like embedded comments from above. _(preferred solution)_
            # TODO: _Alternative (b)_: Improve folded comments visual appearance in single-column view. _(easy solution)_
            #
            # ^ … if we start this comment with “^” instead of “}” it and all
            # } code up to the next segment's first comment starts folded
            if foldPrefix? and comment.indexOf(foldPrefix) is 0

              # } … so folding stops below, as this is a new segment !
              # Let's strip the “^” character from our documentation
              currSegment.foldMarker = line.replace singleStrip, '$1'

              # And collect it as code.
              currSegment.code.push currSegment.foldMarker
            else
              currSegment.comments.push comment

      # We surely (should) have raw code at this point.
      else
        currSegment.code.push line

    segments.push currSegment

    segments

  # Just a convenient prototype for building segments
  Segment: class Segment
    constructor: (code=[], comments=[], foldMarker='') ->
      @code     = code
      @comments = comments
      @foldMarker = foldMarker
