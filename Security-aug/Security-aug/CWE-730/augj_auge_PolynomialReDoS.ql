/**
 * @name Polynomial regular expression used on uncontrolled data
 * @description Identifies regular expressions exhibiting polynomial time complexity
 *              that could lead to denial-of-service when processing untrusted input.
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
// Import module for analyzing polynomial complexity regex vulnerabilities
import semmle.python.security.dataflow.PolynomialReDoSQuery
// Import PathGraph for tracking data flow paths
import PolynomialReDoSFlow::PathGraph

// Define source and target nodes for data flow analysis
from
  // Source node represents the origin of untrusted data
  PolynomialReDoSFlow::PathNode sourceNode, PolynomialReDoSFlow::PathNode targetNode,
  // Sink node identifies where vulnerable regex is applied
  Sink vulnerableSink,
  // Problematic regex term that causes exponential backtracking
  PolynomialBackTrackingTerm problematicRegex
where
  // Verify data flows from source to target
  PolynomialReDoSFlow::flowPath(sourceNode, targetNode) and
  // Confirm target node matches our sink definition
  vulnerableSink = targetNode.getNode() and
  // Extract the backtracking regex pattern from the sink
  problematicRegex = vulnerableSink.getABacktrackingTerm()
// Note: Previously excluded URL sources with end-line regex patterns
//   not (
//     sourceNode.getNode().(Source).getKind() = "url" and
//     problematicRegex.isAtEndLine()
//   )
select 
  // Highlight the vulnerable code location and trace data flow
  vulnerableSink.getHighlight(), sourceNode, targetNode,
  // Construct detailed warning message about performance risk
  "This $@ that processes a $@ may exhibit poor performance when handling strings " + 
    problematicRegex.getPrefixMessage() + "containing multiple repetitions of '" + 
    problematicRegex.getPumpString() + "'.", 
  // Reference the problematic regex for code highlighting
  problematicRegex, "regular expression",
  // Identify the uncontrolled input source
  sourceNode.getNode(), "user-provided value"