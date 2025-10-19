import python
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.python.strings.StringUtils

/**
 * @name CWE-918: Server-Side Request Forgery (SSRF)
 */
query {
  // Find instances where user-controlled input is used in a request URL
  (userInputVariable(".*") 
   and call(UrlConstruction, ".*", [arg(UrlPart) = userInput])
   and call(RequestFunction, urlArg = UrlPart)
   and getRequestTarget(urlArg) 
   and isDangerousHost(getRequestTarget(urlArg)))
}

// Predicate to detect user-controlled input variables
predicate userInputVariable(String pattern) {
  exists (CallExpr c, StringLiteral s |
    c.getArgument(0).getValue() = s.getStringValue()
    and s.getValue().matches(pattern))
}

// Predicate to find URL construction operations
predicate UrlConstruction(CallExpr c, String methodName, Arg arg) {
  c.getMethodName() = methodName
  arg.getType().getName() = "str"
}

// Predicate to identify request functions (e.g., requests.get, urllib.request.urlopen)
predicate RequestFunction(CallExpr c, Arg urlArg) {
  c.getMethodName() in ["get", "post", "open", "urlopen"]
  urlArg.getType().getName() = "str"
}

// Extract the target host from a URL
string getRequestTarget(string url) {
  if (url.startsWith("http://")) {
    return substr(url, 7, length(url) - 7)
  } else if (url.startswith("https://")) {
    return substr(url, 8, length(url) - 8)
  } else {
    return url
  }
}

// Check if the request target is dangerous (internal hosts/paths)
predicate isDangerousHost(string host) {
  host matches /^localhost$/
  or host matches /^127\.0\.0\.1$/
  or host matches /^10\./
  or host matches /^172\.16\./
  or host matches /^172\.17\./
  or host matches /^172\.18\./
  or host matches /^172\.19\./
  or host matches /^172\.20\./
  or host matches /^172\.21\./
  or host matches /^172\.22\./
  or host matches /^172\.23\./
  or host matches /^172\.24\./
  or host matches /^172\.25\./
  or host matches /^172\.26\./
  or host matches /^172\.27\./
  or host matches /^172\.28\./
  or host matches /^172\.29\./
  or host matches /^172\.30\./
  or host matches /^172\.31\./
  or host matches /^192\.168\./
}