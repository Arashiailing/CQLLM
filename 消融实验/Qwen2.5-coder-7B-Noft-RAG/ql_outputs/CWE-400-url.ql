/**
* @name CWE-400: Uncontrolled Resource Consumption
*
@description The product does not properly control the allocation
    and maintenance of a limited resource.
* @kind path-problem
* @problem.severity warning
* @precision high
* @security-severity 7.5
*
@id py/url
*/
import python
import semmle.python.security.dataflow.PolynomialReDoSQuery
from PolynomialReDoSFlow::PathNode source, PolynomialReDoSFlow::PathNode sink, Sink sinkNode, PolynomialBackTrackingTerm regexp
    where PolynomialReDoSFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "URL parameter is vulnerable to Polymorphic RedoS attack.", source.getNode(), "uncontrolled input"