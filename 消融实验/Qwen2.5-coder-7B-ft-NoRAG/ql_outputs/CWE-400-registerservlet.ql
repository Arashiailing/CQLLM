/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @description The product does not properly control the allocation and maintenance of a limited resource.
 * @id py/registerservlet
 */
import python
import semmle.python.security.dataflow.PolynomialReDoSQuery

from PolynomialReDoSFlow::PathNode source, PolynomialReDoSFlow::PathNode sink,
     Sink sinkNode,
     PolynomialBackTrackingTerm regexp
where PolynomialReDoSFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Resource consumption depends on a $@.", source.getNode(), "uncontrolled value"