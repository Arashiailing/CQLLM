import python

/**
 * This query detects CWE-601: URL redirection from a remote source.
 * It looks for cases where user input is directly used to construct
 * a URL for redirection without proper validation.
 */

from Expr userInput, Call redirectCall, Expr urlExpr
where
  // Find calls to functions that perform redirection
  redirectCall.getCallee().getName() = "redirect" and
  // The URL expression is constructed using user input
  urlExpr instanceof ConcatExpr and
  urlExpr.hasArgument(userInput) and
  // The URL expression is passed to the redirection function
  redirectCall.getArgument(0) = urlExpr
select userInput, "Unvalidated user input is used to construct a URL for redirection."