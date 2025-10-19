import python

/**
 * Reflected server-side cross-site scripting (XSS) vulnerability.
 */
class ReflectedXssQuery extends Query {
  ReflectedXssQuery() {
    this.name = "Reflected server-side cross-site scripting"
    this.description = "Writing user input directly to a web page allows for a cross-site scripting vulnerability."
    this.id = "py/reviewtags"
  }

  /**
   * Returns true if the given expression is a potential XSS vulnerability.
   */
  boolean isXssVulnerability(Expression expr) {
    // Check if the expression is a call to a function that writes to a web page
    if (expr instanceof CallExpr callExpr) {
      // Check if the function is a known web page writing function
      if (callExpr.getCallee() instanceof FunctionRef functionRef) {
        string functionName = functionRef.getName()
        if (functionName == "write" || functionName == "writeln" || functionName == "send") {
          // Check if the first argument of the function is user input
          if (callExpr.getArgument(0) instanceof UserInput userInput) {
            return true
          }
        }
      }
    }
    return false
  }

  /**
   * Returns the set of potential XSS vulnerabilities in the given file.
   */
  set<Expression> getVulnerabilities(File file) {
    set<Expression> vulnerabilities = set()
    foreach (expr in file.getExprs()) {
      if (isXssVulnerability(expr)) {
        vulnerabilities.add(expr)
      }
    }
    return vulnerabilities
  }
}