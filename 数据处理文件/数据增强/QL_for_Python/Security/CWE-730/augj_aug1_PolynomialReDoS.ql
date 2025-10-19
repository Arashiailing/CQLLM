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

// Import Python analysis framework
import python
// Import specialized module for regex vulnerability detection
import semmle.python.security.dataflow.PolynomialReDoSQuery
// Import path graph utilities for data flow tracking
import PolynomialReDoSFlow::PathGraph

// Define the components of our data flow analysis
from
  // Source node represents entry point of uncontrolled data
  PolynomialReDoSFlow::PathNode sourceNode,
  // Destination node represents where regex is applied
  PolynomialReDoSFlow::PathNode destNode,
  // Vulnerable sink where regex matching occurs
  Sink vulnerableSink,
  // Problematic regex pattern causing potential backtracking
  PolynomialBackTrackingTerm vulnerableRegex
where
  // Verify data flows from source to destination
  PolynomialReDoSFlow::flowPath(sourceNode, destNode) and
  // Link destination node to the sink object
  vulnerableSink = destNode.getNode() and
  // Extract the problematic regex from the sink
  vulnerableRegex = vulnerableSink.getABacktrackingTerm()
// Previously disabled filter for URL sources with end-of-line patterns
//   not (
//     sourceNode.getNode().(Source).getKind() = "url" and
//     vulnerableRegex.isAtEndLine()
//   )
select
  // Return the highlighted sink and path nodes
  vulnerableSink.getHighlight(), sourceNode, destNode,
  // Generate descriptive warning message about performance impact
  "This $@ that depends on a $@ may run slow on strings " + vulnerableRegex.getPrefixMessage() +
    "with many repetitions of '" + vulnerableRegex.getPumpString() + "'.",
  // Identify the problematic regex for highlighting
  vulnerableRegex, "regular expression",
  // Identify the source of uncontrolled input
  sourceNode.getNode(), "user-provided value"