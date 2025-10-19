/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @id py/client-cwe-400
 */
import python
import semmle.python.security.dataflow.PolynomialReDoSQuery
import PolynomialReDoSFlow::PathGraph

from PolynomialReDoSFlow::PathNode source, PolynomialReDoSFlow::PathNode sink
where PolynomialReDoSFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Regular expression may cause polynomial time consumption", source.getNode(), "uncontrolled input"