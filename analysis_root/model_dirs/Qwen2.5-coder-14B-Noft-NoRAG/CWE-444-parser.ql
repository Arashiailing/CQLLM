import python

/**
 * This query detects CWE-444: Inconsistent Interpretation of HTTP Requests ('HTTP Request/Response Smuggling').
 * It looks for potential HTTP header injection vulnerabilities in Python code.
 */

class HttpRequestHeaderInjection extends DataFlow::Node {
  HttpRequestHeaderInjection() {
    exists(CallExpr call |
      call.getCallee().getName() = "add_header" and
      call.getArgument(0).(StringLiteral).getValue() = "Content-Length"
    )
  }
}

class HttpResponseHeaderInjection extends DataFlow::Node {
  HttpResponseHeaderInjection() {
    exists(CallExpr call |
      call.getCallee().getName() = "set_header" and
      call.getArgument(0).(StringLiteral).getValue() = "Content-Length"
    )
  }
}

from HttpRequestHeaderInjection request, HttpResponseHeaderInjection response
select request, response, "Potential HTTP Request/Response Smuggling vulnerability detected."