import python

/**
 * CWE-400: Uncontrolled Resource Consumption
 * This query detects potential Polynomial Regular Expression Denial of Service (ReDoS) vulnerabilities.
 */

class PolynomialReDoSQuery extends Query {
  PolynomialReDoSQuery() {
    this.getName() = "CWE-400: Uncontrolled Resource Consumption"
    this.getDescription() = "The product does not properly control the allocation and maintenance of a limited resource."
    this.getId() = "py/url"
  }

  override predicate run() {
    // Find function calls to regex methods that might be vulnerable to ReDoS
    for (Call call : Call) {
      if (call.getCallee().getName() = "match" or call.getCallee().getName() = "search") {
        // Check if the regex pattern is a literal string
        for (Argument arg : call.getArgument(0)) {
          if (arg instanceof StringLiteral) {
            // Check if the pattern is a simple or common vulnerable pattern
            string pattern = arg.getValue()
            if (pattern matches ".*\\*.*" or pattern matches ".*\\+.*" or pattern matches ".*\\{.*\\}.*") {
              // Report the vulnerability
              report(call, "Potential Polynomial ReDoS vulnerability detected due to regex pattern: " + pattern)
            }
          }
        }
      }
    }
  }
}