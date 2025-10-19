import python

/**
 * This query detects CWE-601: URL Redirection to Untrusted Site
 * by finding instances where user input is used to construct a URL
 * for redirection without proper validation.
 */

from HttpRequest req, String userInput, String redirectUrl
where
  // Find HTTP requests that include user input
  req.getArgument(userInput) and
  // Find redirections using the user input
  redirectUrl = req.getArgument(userInput) and
  // Check if the redirection URL is constructed without validation
  not exists(ValidationCall validation | validation.getArgument(redirectUrl))
select
  req,
  "Potentially vulnerable URL redirection detected. User input is used to construct the redirection URL without proper validation."