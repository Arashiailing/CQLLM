/** @name CWE-400: Uncontrolled Resource Consumption */
import python
import semmle.python.security.dataflow.PolynomialReDoSQuery
import PolynomialReDoSFlow::PathGraph

from PolynomialReDoSFlow::PathNode source, PolynomialReDoSFlow::PathNode sink
where PolynomialReDoSFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Resource consumption due to polynomial-time regex", source.getNode(), "uncontrolled input"