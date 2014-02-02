expect = require('chai').expect
Buffer = require('buffer').Buffer
path = require('path')
fs = require('fs')
es = require('event-stream')
gutil = require('gulp-util')

t = require('../../lib/transforms')
LANGUAGES = require '../../lib/languages'

describe "Syntax Highlighting", ->
  fakeContent = new Buffer(fs.readFileSync(
    path.join(__dirname, '..', '..', 'lib', 'generator.coffee')
  ))

  fakeFile = null
  highlight = null

  beforeEach ->
    fakeFile = new gutil.File
      cwd: "/",
      base: "/test/",
      path: "/test/file.coffee"
      contents: fakeContent
    # Set file language
    fakeFile.extra = lang: LANGUAGES.CoffeeScript

    highlight = t.highlight()

  it "should export a function", ->
    expect(t.highlight).to.be.a('function')

  it "should highlight file contents when there are no segments", (done) ->
    highlight
    .once 'data', (file) ->
      expect(file.isBuffer()).to.be.true
      expect(file.contents).to.be.an.instanceof(Buffer)
      expect(file.path).to.match /\.html$/
      done()
    .on 'error', done

    highlight.write(fakeFile)

  it "should highlight file segments", (done) ->
    segmentate = t.splitCodeAndComments()
    
    segmentate
    .pipe(highlight)
    .once 'data', (file) ->
      expect(file.isBuffer()).to.be.true
      expect(file.segments).to.be.an('array')
      expect(file.path).to.not.match /\.html$/
      done()
    .on 'error', done

    segmentate.write(fakeFile)

  it "shouldn't fail for unknown languages", (done) ->
    crazyFile = new gutil.File
      cwd: "/",
      base: "/test/",
      path: "/test/file"
      contents: new Buffer """$1: `adsa`; and (echo 'yay'); (a b).map -> adas"""

    highlight
    .once 'data', (file) ->
      expect(file.contents).to.be.an('object')
      expect(file.path).to.match /\.html$/
      done()
    .on 'error', done

    highlight.write(crazyFile)

  it "should throw for unsupported languages", (done) ->
    fakeFile.extra = lang: {highlightJS: 'beer'}

    highlight
    .once 'data', (file) ->
      done new Error "Should have failed."
    .on 'error', (err) ->
      expect(err).to.be.an.instanceof(Error)
      done()

    highlight.write(fakeFile)
