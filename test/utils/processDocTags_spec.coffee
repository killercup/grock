expect = require('chai').expect
Buffer = require('buffer').Buffer

process = require '../../lib/utils/processDocTags'

# ## Fake data
#
# Parsing starts with one empty description tag, so add that one to `tagCount`.

docTagsValid = code: """
# @method Parse Doc Tags
# @description Parses comments of segment for doc tags. Adds `tags` and
#   `tagSections` to each segment.
# @param {Array} segments `[{code, comments}]`
# @param {String} segments.code
# @return {Promise} Resolves when segment comments have been processed
""".trim(), tagCount: 5 + 1, keys: ['description', 'params', 'returns']

docTagsInvalid = code: """
# ## Parse Doc Tags
# @description Parses comments of segment for doc tags. Adds `tags` and
#   `tagSections` to each segment.
# @param
# @
# @return Resolves when segment comments have been processed
""".trim(), tagCount: 4, keys: ['description', 'params', 'returns']

describe "Documentation Tags", ->
  describe "Parsing", ->
    it "should work for correct doc tags", (done) ->
      process
      .parseDocTags [{code: "", comments: docTagsValid.code.split('\n')}]
      .then ([segment]) ->
        expect(segment.tags).to.be.an('array')
        expect(segment.tags.length).to.eql docTagsValid.tagCount
        expect(segment.tagSections).to.be.an('object')
        expect(segment.tagSections).to.contain.keys(docTagsValid.keys)
        expect(segment.tagSections.returns.length).to.eql 1
      .then -> done()
      .then null, done

    it "should not throw when incorrent tags are present", (done) ->
      process
      .parseDocTags [{code: "", comments: docTagsInvalid.code.split('\n')}]
      .then ([segment]) ->
        expect(segment.tags).to.be.an('array')
        expect(segment.tags.length).to.eql docTagsInvalid.tagCount
        expect(segment.tagSections).to.be.an('object')
        expect(segment.tagSections).to.contain.keys(docTagsInvalid.keys)
        expect(segment.tagSections.returns.length).to.eql 1
      .then -> done()
      .then null, done

  describe "Convert to Markdown", ->
    it "should work for correct doc tags", (done) ->
      process
      .parseDocTags [{code: "", comments: docTagsValid.code.split('\n')}]
      .then process.markdownDocTags
      .then ([{tags}]) ->
        expect(tags).to.be.an('array')
        expect(tags.length).to.be.above 0

        tags.forEach (tag) ->
          expect(tag.markdown).to.exist
      .then -> done()
      .then null, done

    it "should not throw when incorrent tags are present", (done) ->
      process
      .parseDocTags [{code: "", comments: docTagsInvalid.code.split('\n')}]
      .then process.markdownDocTags
      .then ([{tags}]) ->
        expect(tags).to.be.an('array')
        expect(tags.length).to.be.above 0

        tags.forEach (tag) ->
          expect(tag.markdown).to.exist
      .then -> done()
      .then null, done

  describe "Combine to HTML", ->
    it "should write all doc tags to segment comments", (done) ->
      process
      .parseDocTags [{code: "", comments: docTagsValid.code.split('\n')}]
      .then process.markdownDocTags
      .then process.renderDocTags
      .then ([{comments}]) ->
        # Actually, it's an array of lines for some reason
        expect(comments).to.be.an('array')
        expect(comment = comments.join('\n')).to.be.a('string')

        # Some values from the fake data above
        expect(comment).to.contain('Parse Doc Tags')
        expect(comment).to.contain('Parameters:')
        expect(comment).to.contain('Parses comments of segment for')
        expect(comment).to.contain('Promise')
      .then -> done()
      .then null, done

