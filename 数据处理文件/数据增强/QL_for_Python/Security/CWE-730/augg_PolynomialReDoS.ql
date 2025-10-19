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

// Import Python language support
import python
// Import polynomial ReDoS detection module
import semmle.python.security.dataflow.PolynomialReDoSQuery
// Import path graph analysis utilities
import PolynomialReDoSFlow::PathGraph

// Define core analysis components
from
  // Identify source and sink nodes in data flow
  PolynomialReDoSFlow::PathNode sourceNode, PolynomialReDoSFlow::PathNode sinkPathNode,
  // Map sink to vulnerable regex pattern
  Sink sinkNode,
  // Extract problematic regex component
  PolynomialBackTrackingTerm vulnerableRegex
where
  // Verify data flow path exists
  PolynomialReDoSFlow::flowPath(sourceNode, sinkPathNode) and
  // Connect sink node to vulnerable pattern
  sinkNode = sinkPathNode.getNode() and
  // Identify regex backtracking term
  vulnerableRegex = sinkNode.getABacktrackingTerm()
// Disabled filter condition (preserved for reference)
//   not (
//     sourceNode.getNode().(Source).getKind() = "url" and
//     vulnerableRegex.isAtEndLine()
//   )
select
  // Highlight sink location in code
  sinkNode.getHighlight(), sourceNode, sinkPathNode,
  // Construct vulnerability message
  "This $@ that depends on a $@ may run slow on strings " + vulnerableRegex.getPrefixMessage() +
    "with many repetitions of '" + vulnerableRegex.getPumpString() + "'.",
  // Annotate regex pattern
  vulnerableRegex, "regular expression",
  // Annotate data source
  sourceNode.getNode(), "user-provided value"