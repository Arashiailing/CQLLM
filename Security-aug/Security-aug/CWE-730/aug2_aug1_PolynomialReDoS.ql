/**
 * @name Polynomial regular expression used on uncontrolled data
 * @description Regular expressions requiring polynomial matching time
 *              may cause denial-of-service vulnerabilities.
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
// Import polynomial-time ReDoS detection module
import semmle.python.security.dataflow.PolynomialReDoSQuery
// Import data flow path tracking utilities
import PolynomialReDoSFlow::PathGraph

// Define data flow path components
from
  // Source node representing uncontrolled input
  PolynomialReDoSFlow::PathNode sourceNode, 
  // Terminal node in data flow path
  PolynomialReDoSFlow::PathNode terminalNode,
  // Sink where regex is applied
  Sink regexSink,
  // Vulnerable regex pattern
  PolynomialBackTrackingTerm vulnerableRegex
where
  // Verify complete data flow path exists
  PolynomialReDoSFlow::flowPath(sourceNode, terminalNode) and
  // Map terminal node to regex sink
  regexSink = terminalNode.getNode() and
  // Extract vulnerable regex from sink
  vulnerableRegex = regexSink.getABacktrackingTerm()
// Disabled filter: Exclude URL sources with end-of-line patterns
//   not (
//     sourceNode.getNode().(Source).getKind() = "url" and
//     vulnerableRegex.isAtEndLine()
//   )
select
  // Highlight vulnerable code locations
  regexSink.getHighlight(), sourceNode, terminalNode,
  // Generate vulnerability description
  "This $@ processing a $@ may exhibit slow performance " + vulnerableRegex.getPrefixMessage() +
    "when encountering repeated instances of '" + vulnerableRegex.getPumpString() + "'.",
  // Identify vulnerable regex pattern
  vulnerableRegex, "regular expression",
  // Identify uncontrolled data source
  sourceNode.getNode(), "user-provided input"