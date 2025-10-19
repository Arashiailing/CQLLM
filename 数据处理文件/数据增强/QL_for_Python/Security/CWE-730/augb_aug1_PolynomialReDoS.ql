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

// Define vulnerable components for analysis
from
  // Source node representing uncontrolled input data
  PolynomialReDoSFlow::PathNode sourceNode,
  // Sink node where regex is applied to uncontrolled data
  PolynomialReDoSFlow::PathNode sinkNode,
  // Vulnerable regex usage location
  Sink vulnerableSink,
  // Regex pattern with exponential backtracking risk
  PolynomialBackTrackingTerm riskyRegex
where
  // Verify data flow path exists from source to sink
  PolynomialReDoSFlow::flowPath(sourceNode, sinkNode) and
  // Confirm sink node matches vulnerable regex usage
  vulnerableSink = sinkNode.getNode() and
  // Extract problematic regex pattern from sink
  riskyRegex = vulnerableSink.getABacktrackingTerm()
// Disabled filter: exclude cases where source is URL and regex matches end of line
//   not (
//     sourceNode.getNode().(Source).getKind() = "url" and
//     riskyRegex.isAtEndLine()
//   )
select
  // Highlight vulnerable regex usage location
  vulnerableSink.getHighlight(), sourceNode, sinkNode,
  // Generate warning message with performance impact details
  "This $@ that depends on a $@ may run slow on strings " + riskyRegex.getPrefixMessage() +
    "with many repetitions of '" + riskyRegex.getPumpString() + "'.",
  // Identify the problematic regular expression
  riskyRegex, "regular expression",
  // Identify the source of uncontrolled data
  sourceNode.getNode(), "user-provided value"