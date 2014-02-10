###
# # Create Public URL
#
# Currently, this works with git repos on Github and Bitbucket.
#
# @param {String} repositoryUrl The URL to the publice repository
# @return {Function} Method mapping file path to public URL.
###
module.exports = (repositoryUrl) ->
  # Remove trailing slash
  repositoryUrl = repositoryUrl.replace /\/$/, ''

  if repositoryUrl.match(/^http(s|)\:\/\/github.com/)
    (path) -> "#{repositoryUrl}/blob/master/#{path}"
  else if repositoryUrl.match(/^http(s|)\:\/\/bitbucket.org/)
    # Assuming, this is git repo. hg repos need `tip` instead of `master`.
    (path) -> "#{repositoryUrl}/src/master/#{path}"
  else
    -> null