/**
 * @name Polynomial regular expression used on uncontrolled data
 * @description Identifies regular expressions with polynomial-time complexity
 *              that could lead to denial-of-service vulnerabilities.
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
// Import module for detecting regex patterns vulnerable to polynomial-time backtracking
import semmle.python.security.dataflow.PolynomialReDoSQuery
// Import path graph utilities for visualizing data flow paths
import PolynomialReDoSFlow::PathGraph

from
  // Define source and sink nodes in the data flow path
  PolynomialReDoSFlow::PathNode sourceNode, PolynomialReDoSFlow::PathNode sinkNode,
  // Define the sink location where the regex is potentially misused
  Sink regexSink,
  // Define the regex pattern that may cause exponential backtracking
  PolynomialBackTrackingTerm problematicPattern
where
  // Establish data flow path from source to sink
  PolynomialReDoSFlow::flowPath(sourceNode, sinkNode) and
  // Connect the sink node to the actual regex sink
  regexSink = sinkNode.getNode() and
  // Extract the problematic regex pattern from the sink
  problematicPattern = regexSink.getABacktrackingTerm()
// Disabled filter: exclude URL sources with end-of-line matching regex
//   not (
//     sourceNode.getNode().(Source).getKind() = "url" and
//     problematicPattern.isAtEndLine()
//   )
select
  // Highlight elements: the sink location, source and sink nodes
  regexSink.getHighlight(), sourceNode, sinkNode,
  // Generate descriptive warning message
  "This $@ that uses a $@ may experience performance degradation " + 
  "when processing strings " + problematicPattern.getPrefixMessage() +
  "containing multiple repetitions of '" + problematicPattern.getPumpString() + "'.",
  // Reference the vulnerable regex pattern
  problematicPattern, "regular expression",
  // Reference the untrusted data source
  sourceNode.getNode(), "user-provided value"