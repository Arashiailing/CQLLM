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

// Import Python standard library for code analysis
import python
// Import specialized module for detecting polynomial-time complexity regex vulnerabilities
import semmle.python.security.dataflow.PolynomialReDoSQuery
// Import path graph utilities for tracking data flow paths
import PolynomialReDoSFlow::PathGraph

// Select data from the following sources
from
  // Define origin and target nodes of the data flow path
  PolynomialReDoSFlow::PathNode originNode, PolynomialReDoSFlow::PathNode targetNode,
  // Define the sink node where potentially vulnerable regex is used
  Sink targetSink,
  // Define the regular expression term that may cause backtracking issues
  PolynomialBackTrackingTerm backtrackingRegex
where
  // Data flow condition: there exists a path from origin to target
  PolynomialReDoSFlow::flowPath(originNode, targetNode) and
  // Sink matching condition: the target node corresponds to our sink
  targetSink = targetNode.getNode() and
  // Regex extraction condition: obtain the backtracking term from the sink
  backtrackingRegex = targetSink.getABacktrackingTerm()
// Disabled filter: exclude cases where source is URL and regex matches end of line
//   not (
//     originNode.getNode().(Source).getKind() = "url" and
//     backtrackingRegex.isAtEndLine()
//   )
select
  // Highlight elements: the sink location, origin, and target nodes
  targetSink.getHighlight(), originNode, targetNode,
  // Construct warning message about potential performance issues
  "This $@ that depends on a $@ may run slow on strings " + backtrackingRegex.getPrefixMessage() +
    "with many repetitions of '" + backtrackingRegex.getPumpString() + "'.",
  // Identify the problematic regular expression
  backtrackingRegex, "regular expression",
  // Identify the source of uncontrolled data
  originNode.getNode(), "user-provided value"