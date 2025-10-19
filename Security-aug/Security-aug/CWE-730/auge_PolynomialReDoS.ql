/**
 * @name Polynomial regular expression used on uncontrolled data
 * @description Detects regular expressions with polynomial time complexity
 *              that may cause denial-of-service when processing untrusted input.
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

// Import Python language library
import python
// Import module for detecting polynomial complexity regular expression issues
import semmle.python.security.dataflow.PolynomialReDoSQuery
// Import PathGraph class for path analysis
import PolynomialReDoSFlow::PathGraph

// Select relevant data sources for analysis
from
  // Define origin and destination nodes in the data flow
  PolynomialReDoSFlow::PathNode dataOrigin, PolynomialReDoSFlow::PathNode dataDestination,
  // Define the sink node where vulnerable regex is used
  Sink destinationNode,
  // Define the regular expression term that causes backtracking
  PolynomialBackTrackingTerm backtrackingRegex
where
  // Ensure there is a data flow path from origin to destination
  PolynomialReDoSFlow::flowPath(dataOrigin, dataDestination) and
  // Match the destination node with our sink definition
  destinationNode = dataDestination.getNode() and
  // Extract the backtracking regular expression from the sink
  backtrackingRegex = destinationNode.getABacktrackingTerm()
// Note: Previously commented out condition excluded URL sources with end-line regex
//   not (
//     dataOrigin.getNode().(Source).getKind() = "url" and
//     backtrackingRegex.isAtEndLine()
//   )
select 
  // Highlight the vulnerable code location and show data flow
  destinationNode.getHighlight(), dataOrigin, dataDestination,
  // Generate descriptive message about the potential performance issue
  "This $@ that depends on a $@ may run slow on strings " + backtrackingRegex.getPrefixMessage() +
    "with many repetitions of '" + backtrackingRegex.getPumpString() + "'.", 
  // Reference the problematic regular expression for highlighting
  backtrackingRegex, "regular expression",
  // Reference the user-controlled input source
  dataOrigin.getNode(), "user-provided value"