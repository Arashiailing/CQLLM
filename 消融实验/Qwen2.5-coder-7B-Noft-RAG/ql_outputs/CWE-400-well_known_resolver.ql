/**
* @name CWE-400: Server-Side Request Forgery (SSRF)
*
@description SSRF occurs when an application includes user-supplied data in URLs
    or requests sent to servers without proper validation
    or sanitization.
* @kind path-problem
* @problem.severity error
* @security-severity 9.1
* @precision medium
*
@id py/ssrf
*/
import python
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
import ServerSideRequestForgeryFlow::PathGraph
from ServerSideRequestForgeryFlow::PathNode source, ServerSideRequestForgeryFlow::PathNode sink, Http::Client::Request request
    where request = sink.getNode().(Sink).getRequest()
    and ServerSideRequestForgeryFlow::flowPath(source, sink)
    and not fullyControlledRequest(request)
    select request, source, sink, "Potential SSRF vulnerability: User-supplied data controls part of the URL.", source.getNode(), "user-provided value"