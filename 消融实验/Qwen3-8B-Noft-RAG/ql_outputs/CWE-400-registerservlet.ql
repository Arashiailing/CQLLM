import python
import semmle.python.security.dataflow.PolynomialReDoSQuery
import PolynomialReDoSFlow::PathGraph

from PolynomialReDoSFlow::PathNode source, PolynomialReDoSFlow::PathNode sink
where PolynomialReDoSFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Polynomial-time regex pattern used on uncontrolled data", source.getNode(), "uncontrolled input"