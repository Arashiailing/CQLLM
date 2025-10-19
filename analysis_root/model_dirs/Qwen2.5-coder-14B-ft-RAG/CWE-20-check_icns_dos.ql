/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 *              not validate or incorrectly validates that the input has the
 *              properties that are required to process the data safely and
 *              correctly.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @id py/check_icns_dos
 * @tags correctness
 *       security
 *       external/cwe/cwe-20
 */

import python
import semmle.python.security.dataflow.PolynomialReDoSQuery
import PolynomialReDoSFlow::PathGraph

from
  PolynomialReDoSFlow::PathNode source, PolynomialReDoSFlow::PathNode sink,
  Sink sinkNode, PolynomialBackTrackingTerm regexp
where
  PolynomialReDoSFlow::flowPath(source, sink) and
  sinkNode = sink.getNode() and
  regexp = sinkNode.asExpr()
select sinkNode, source, sink, "$@ can create a backtracking regex pattern.", regexp, regexp.toString()