import python
import semmle.python.security.dataflow.PolynomialReDoSQuery
import PolynomialReDoSFlow::PathGraph

from PolynomialReDoSFlow::PathNode source, PolynomialReDoSFlow::PathNode sink, PolynomialBackTrackingTerm regexp
where PolynomialReDoSFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This regex pattern may trigger a polynomial-time DoS attack due to backtracking", source.getNode(), "user-provided value"