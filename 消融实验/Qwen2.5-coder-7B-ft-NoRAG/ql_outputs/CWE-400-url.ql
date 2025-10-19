import python
import semmle.python.security.dataflow.PolynomialReDoSQuery

from PolynomialReDoSFlow::PathNode source, PolynomialReDoSFlow::PathNode sink,
     Sink sinkNode, PolynomialBackTrackingTerm regexp
where PolynomialReDoSFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Regular expression depends on a $@.", source.getNode(), "user-provided input"