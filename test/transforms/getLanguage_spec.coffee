expect = require('chai').expect
Buffer = require('buffer').Buffer
es = require('event-stream')
gutil = require('gulp-util')

t = require('../../lib/transforms')
LANGUAGES = require '../../lib/languages'

describe "Get File Language", ->
  fakeCoffeeFile = new gutil.File
    cwd: "/",
    base: "/test/",
    path: "/test/file.coffee"
    contents: new Buffer("test = 123")

  fakeUnknownFile = new gutil.File
    cwd: "/",
    base: "/test/",
    path: "/test/file"
    contents: new Buffer("test = 123")

  getLanguage = t.getLanguage()

  it "should export a function", ->
    expect(t.getLanguage).to.be.a('function')

  it "should add an `extra` and `lang` property", (done) ->
    getLanguage
    .once 'data', (file) ->
      expect(file.isBuffer()).to.be.true
      expect(file.extra).to.be.an('object')
      expect(file.extra.lang).to.exist
      done()
    .on 'error', done

    getLanguage.write(fakeCoffeeFile)

  it "should identify coffee file", (done) ->
    getLanguage
    .once 'data', (file) ->
      expect(file.extra).to.be.an('object')
      expect(file.extra.lang).to.exist
      expect(file.extra.lang).to.eql LANGUAGES.CoffeeScript

      done()
    .on 'error', done

    getLanguage.write(fakeCoffeeFile)

  it "should return null if language is unknown", (done) ->
    getLanguage
    .once 'data', (file) ->
      expect(file.extra).to.be.an('object')
      expect(file.extra.lang).to.be.null
      done()
    .on 'error', done

    getLanguage.write(fakeUnknownFile)
