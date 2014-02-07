expect = require('chai').expect

Buffer = require('buffer').Buffer
fs = require('fs')
path = require('path')

gutil = require('gulp-util')
_ = require('lodash')

seperator = require '../../lib/utils/seperator'
LANGUAGES = require '../../lib/languages'

describe "Seperator for code and comments", ->
  it "should take a string and return an array of segments", ->
    fakeFile = new gutil.File
      cwd: "/", base: "/test/", path: "/test/file.coffee",
      contents: new Buffer(
        fs.readFileSync(path.join(__dirname, '..', '..', 'lib', 'docTags.coffee'))
      )
    fakeFile.extra = lang: LANGUAGES.CoffeeScript

    segments = seperator(fakeFile.contents.toString('utf8'), fakeFile.extra.lang)
    expect(segments).to.be.an('array')
    expect(segments.length).to.be.above 0
    _.every segments, (part) ->
      expect(part.code or part.comments).to.exist
      expect(part.code).to.be.an('array') if part.code
      expect(part.comments).to.be.an('array') if part.comments

  it "should have a shortcut for comment-only files", ->
    fakeFile = new gutil.File
      cwd: "/", base: "/test/", path: "/test/file.md",
      contents: new Buffer(
        fs.readFileSync(path.join(__dirname, '..', '..', 'Readme.md'))
      )
    fakeFile.extra = lang: LANGUAGES.Markdown

    segments = seperator(fakeFile.contents.toString('utf8'), fakeFile.extra.lang)
    expect(segments).to.be.an('array')
    expect(segments.length).to.eql 1
    expect(segments[0].comments.length).to.be.above 0
    expect(segments[0].code.length).to.eql 0

  it "should have a shortcut for code-only files", ->
    fakeFile = new gutil.File
      cwd: "/", base: "/test/", path: "/test/file.json",
      contents: new Buffer(
        fs.readFileSync(path.join(__dirname, '..', '..', 'package.json'))
      )
    fakeFile.extra = lang: LANGUAGES.JSON

    segments = seperator(fakeFile.contents.toString('utf8'), fakeFile.extra.lang)
    expect(segments).to.be.an('array')
    expect(segments.length).to.eql 1
    expect(segments[0].comments.length).to.eql 0
    expect(segments[0].code.length).to.be.above 0
