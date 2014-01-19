###
# # Regex Escape
###

_ = require 'lodash'

# Code from <http://zetafleet.com/>
# via <http://blog.simonwillison.net/post/57956816139/escape>
regexpEscapePattern = /[-[\]{}()*+?.,\\^$|#\s]/g
regexpEscapeReplace = '\\$&'

###
# @method Regex Escape
# @description Escape regular expression characters in a String, an Array of
# Strings or any Object having a proper toString-method.
# @param {Array|String} obj (List of) strings to escape for regex
# @return {Array|String} Escaped (list of) regex
###
module.exports = regexpEscape = (obj) ->
  if _.isArray obj
    _.invoke(obj, 'replace', regexpEscapePattern, regexpEscapeReplace)
  else if _.isString obj
    obj.replace(regexpEscapePattern, regexpEscapeReplace)
  else
    regexpEscape "#{obj}"
