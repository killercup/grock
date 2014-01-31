expect = require('chai').expect
path = require('path')
fs = require('fs')
es = require('event-stream')
gutil = require('gulp-util')

t = require('../../lib/transforms')
LANGUAGES = require '../../lib/languages'

describe "Split Code and Comments", ->
  fakeFile = new gutil.File
    cwd: "/",
    base: "/test/",
    path: "/test/file.coffee"
    contents: new Buffer(
      fs.readFileSync(
        path.join(__dirname, '..', '..', 'lib', 'docTags.coffee')
      )
    )
  # Set file language
  fakeFile.extra = lang: LANGUAGES.CoffeeScript

  splitCodeAndComments = t.splitCodeAndComments()

  it "should export a function", ->
    expect(t.splitCodeAndComments).to.be.a('function')

  it "should split file into segments", (done) ->
    splitCodeAndComments
    .once 'data', (file) ->
      expect(file.isBuffer()).to.be.true
      expect(file.segments).to.be.an('array')
      expect(file.segments.length).to.be.gt 0
      done()
    .on 'error', done

    splitCodeAndComments.write(fakeFile)
