/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @id py/stringutils
 */
import python
import semmle.python.security.dataflow.PolynomialReDoSQuery
import PolynomialReDoSFlow::PathGraph

from PolynomialReDoSFlow::PathNode source, PolynomialReDoSFlow::PathNode sink, PolynomialBackTrackingTerm regexp
where
  PolynomialReDoSFlow::flowPath(source, sink)
  and regexp.getBacktrackingTerms()
select sink.getNode(), source, sink, "Polynomial regular expression used on uncontrolled data", source.getNode(), "user-provided value"