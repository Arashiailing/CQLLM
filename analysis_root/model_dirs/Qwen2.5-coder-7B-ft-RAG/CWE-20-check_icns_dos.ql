/**
 * @name Polynomial regular expression used on uncontrolled data
 * @description A regular expression that can require polynomial time
 *              to match may be vulnerable to denial-of-service attacks.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @id py/polynomial-redos
 * @tags security
 *       external/cwe/cwe-1333
 *       external/cwe/cwe-730
 *       external/cwe/cwe-400
 */
import python
import semmle.python.security.dataflow.PolynomialReDoSQuery
import PolynomialReDoSFlow::PathGraph
from
  PolynomialReDoSFlow::PathNode source,
  PolynomialReDoSFlow::PathNode sink,
  Sink sinkNode,
  PolynomialBackTrackingTerm regexp
where
  PolynomialReDoSFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "XPath expression depends on a $@.", source.getNode(),  "user-provided value"