import python

/**
 * CWE-93: Improper Neutralization of CRLF Sequences ('CRLF Injection')
 * Detects potential CRLF injection vulnerabilities in Bottle.py applications.
 */

from FunctionCall call, DataFlow::Node source, DataFlow::Node sink
where
  // Check if the function call is related to HTTP response headers
  call.getCallee().getName() = "response.headers.add" and
  // Check if the source of the data is user input
  DataFlow::localFlow(source, call.getArgument(1)) and
  // Check if the sink is an HTTP response header
  DataFlow::localFlow(call.getArgument(1), sink) and
  // Check if the source contains CRLF sequences
  exists(StringLiteral literal | literal = source.asExpr() and literal.getValue().contains("\r\n"))
select call, "Potential CRLF injection vulnerability detected in HTTP response header."