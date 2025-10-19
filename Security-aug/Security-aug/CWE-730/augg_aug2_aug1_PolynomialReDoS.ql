/**
 * @name Regular expression with polynomial complexity on user input
 * @description Regular expressions that exhibit polynomial time complexity
 *              during matching can lead to denial-of-service attacks.
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

// Import the Python analysis framework
import python
// Import the module for detecting polynomial-time ReDoS vulnerabilities
import semmle.python.security.dataflow.PolynomialReDoSQuery
// Import utilities for tracking data flow paths
import PolynomialReDoSFlow::PathGraph

// Identify components of the data flow path
from
  // Origin of uncontrolled input
  PolynomialReDoSFlow::PathNode inputOrigin, 
  // Endpoint of the data flow path
  PolynomialReDoSFlow::PathNode pathEndpoint,
  // Point where regex is applied
  Sink regexApplicationPoint,
  // Regular expression pattern with risk
  PolynomialBackTrackingTerm riskyPattern
where
  // Ensure there's a complete data flow path
  PolynomialReDoSFlow::flowPath(inputOrigin, pathEndpoint) and
  // Connect path endpoint to regex application
  regexApplicationPoint = pathEndpoint.getNode() and
  // Identify the vulnerable regex pattern
  riskyPattern = regexApplicationPoint.getABacktrackingTerm()
// Disabled filter: Exclude URL sources with end-of-line patterns
//   not (
//     inputOrigin.getNode().(Source).getKind() = "url" and
//     riskyPattern.isAtEndLine()
//   )
select
  // Highlight the vulnerable code locations
  regexApplicationPoint.getHighlight(), inputOrigin, pathEndpoint,
  // Generate vulnerability description
  "This $@ processing a $@ may exhibit slow performance " + riskyPattern.getPrefixMessage() +
    "when encountering repeated instances of '" + riskyPattern.getPumpString() + "'.",
  // Identify the vulnerable regex pattern
  riskyPattern, "regular expression",
  // Identify the source of uncontrolled data
  inputOrigin.getNode(), "user-provided input"