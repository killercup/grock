expect = require('chai').expect
Buffer = require('buffer').Buffer
gutil = require('gulp-util')

t = require '../../lib/transforms'
LANGUAGES = require '../../lib/languages'

docTagsValid = code: """
# @method Parse Doc Tags
# @description Parses comments of segment for doc tags. Adds `tags` and
#   `tagSections` to each segment.
# @param {Array} segments `[{code, comments}]`
# @param {String} segments.code
# @return {Promise} Resolves when segment comments have been processed
""".trim(), tagCount: 5 + 1, keys: ['description', 'params', 'returns']

describe "Rendering Doc Tags", ->
  fakeFile = null
  renderDocTags = null

  beforeEach ->
    fakeFile = new gutil.File
      cwd: "/",
      base: "/test/",
      path: "/test/file.coffee"
      contents: new Buffer "testDate = new Date()"
    fakeFile.extra = lang: LANGUAGES.CoffeeScript

    renderDocTags = t.renderDocTags()

  it "should export a function", ->
    expect(t.renderDocTags).to.be.a('function')

  it "should transform the segments comments", (done) ->
    fakeFile.segments = [{code: "", comments: docTagsValid.code.split('\n')}]

    renderDocTags
    .once 'data', (file) ->
      expect(file.isBuffer()).to.be.true
      expect(file.contents).to.be.an.instanceof(Buffer)

      comments = file.segments[0].comments.join('\n')
      expect(comments).to.be.a('string')
      # Section title
      expect(comments).to.contain 'Parameters:'
      # Markdown for bold
      expect(comments).to.contain '**'
      done()
    .on 'error', done

    renderDocTags.write(fakeFile)
