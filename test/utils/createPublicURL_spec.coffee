expect = require('chai').expect

createPublicURL = require '../../lib/utils/createPublicURL'

describe "Create Public URL", ->
  it "should work for Github", ->
    url = 'https://github.com/killercup/grock'
    pub = createPublicURL(url)

    expect(pub).to.be.a('function')
    expect(pub 'Readme.md').to.eql 'https://github.com/killercup/grock/blob/master/Readme.md'
  
  it "should work for Bitbucket", ->
    url = 'https://bitbucket.org/killercup/grock'
    pub = createPublicURL(url)

    expect(pub).to.be.a('function')
    expect(pub 'Readme.md').to.eql 'https://bitbucket.org/killercup/grock/src/master/Readme.md'

  it "should return null for unknown hosters", ->
    url = 'https://cvs-service.com/killercup/grock'
    pub = createPublicURL(url)

    expect(pub).to.be.a('function')
    expect(pub 'Readme.md').to.be.null

  it "should remove double slashs", ->
    pub = createPublicURL 'https://github.com/killercup/grock/'
    expect(pub 'Readme.md').to.eql 'https://github.com/killercup/grock/blob/master/Readme.md'
