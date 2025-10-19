/**
* @name CWE-400: Uncontrolled Resource Consumption
*
@description The product does not properly control the allocation
    and maintenance of a limited resource.
*
@id py/client-cwe-400
*/
import python
import semmle.python.security.dataflow.PolynomialReDoSQuery
import PolynomialReDoSFlow::PathGraph
from PolynomialReDoSFlow::PathNode source, PolynomialReDoSFlow::PathNode sink, Sink sinkNode, PolynomialBackTrackingTerm regexp
    where PolynomialReDoSFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Regular expression depends on a $@.", source.getNode(), "user-provided input"