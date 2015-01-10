require('coffee-script/register');

require('chai').config.includeStack = true;

require('./demo');

describe("Transforms", function () {
  require('./transforms/getLanguage_spec');
  require('./transforms/splitCodeAndComments_spec');
  require('./transforms/highlight_spec');
  require('./transforms/renderDocTags_spec');
  require('./transforms/indexFile_spec');
  require('./transforms/indexFiles_spec');
});

describe("Utils", function () {
    require('./utils/processDocTags_spec');
    require('./utils/seperator_spec');
    require('./utils/createPublicURL_spec');
    require('./utils/getExtraContent_spec');
})

require('./styles_spec');
