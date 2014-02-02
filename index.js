require('coffee-script/register');

var pkg = require('./package.json');

module.exports = {
  name: pkg.name,
  version: pkg.version,
  generator: require('./lib/generator')
};
