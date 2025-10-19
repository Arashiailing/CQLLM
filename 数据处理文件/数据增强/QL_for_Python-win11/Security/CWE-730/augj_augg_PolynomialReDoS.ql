/**
 * @name Uncontrolled data processed with polynomial-time regular expression
 * @description Regular expressions that can require polynomial time
 *              for matching are susceptible to denial-of-service attacks.
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

// Import required modules for Python analysis
import python
// Import detection capabilities for polynomial ReDoS vulnerabilities
import semmle.python.security.dataflow.PolynomialReDoSQuery
// Import utilities for path graph construction and analysis
import PolynomialReDoSFlow::PathGraph

// Define core analysis components
from
  // Identify origin and destination in data flow
  PolynomialReDoSFlow::PathNode originNode, PolynomialReDoSFlow::PathNode destinationNode,
  // Map destination to vulnerable regex pattern
  Sink destinationSink,
  // Extract problematic regex component
  PolynomialBackTrackingTerm problematicRegex
where
  // Establish data flow connection
  PolynomialReDoSFlow::flowPath(originNode, destinationNode) and
  // Link destination node to its sink representation
  destinationSink = destinationNode.getNode() and
  // Identify the problematic regex pattern causing backtracking
  problematicRegex = destinationSink.getABacktrackingTerm()
// Disabled filter condition (preserved for reference)
//   not (
//     originNode.getNode().(Source).getKind() = "url" and
//     problematicRegex.isAtEndLine()
//   )
select
  // Highlight sink location in code
  destinationSink.getHighlight(), originNode, destinationNode,
  // Construct vulnerability message
  "This $@ that depends on a $@ may run slow on strings " + problematicRegex.getPrefixMessage() +
    "with many repetitions of '" + problematicRegex.getPumpString() + "'.",
  // Annotate regex pattern
  problematicRegex, "regular expression",
  // Annotate data source
  originNode.getNode(), "user-provided value"