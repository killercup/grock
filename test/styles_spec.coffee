expect = require('chai').expect

fs = require 'fs'
path = require("path")

describe "Grock Styles", ->
  stylesPath = path.join(__dirname, '..', 'styles')
  styles = []

  it "should find some styles", ->
    fs.readdirSync(stylesPath)
    .map (file) -> path.join(stylesPath, file)
    .filter (file) -> fs.statSync(file).isDirectory()
    .forEach (dir) ->
      # Each style directory should contain an `index.{js,coffee}`
      styles.push require(dir)

    expect(styles.length).to.be.above 0

  describe "Each Style", ->
    it "should export the necessary methods", ->
      styles.forEach (style) ->
        expect(style.getTemplate).to.be.a('function')
        expect(style.copy).to.be.a('function')
        expect(style.compile).to.be.a('function')

    it "should offer a template function", ->
      styles.forEach (style) ->
        # Get template
        tpl = style.getTemplate()
        # Template is a function that takes at least one parameter
        # (the data object).
        expect(tpl).to.be.a('function')
        expect(tpl.length).to.be.at.least 1
