/**
 * @name Polynomial regular expression used on uncontrolled data
 * @description Identifies regular expressions that may require polynomial time
 *              to match, potentially leading to denial-of-service attacks.
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

// Import necessary Python analysis modules
import python
// Import module for detecting polynomial complexity regex issues
import semmle.python.security.dataflow.PolynomialReDoSQuery
// Import PathGraph for flow path analysis
import PolynomialReDoSFlow::PathGraph

// Define data sources for analysis
from
  // Path nodes representing data flow origin and destination
  PolynomialReDoSFlow::PathNode dataOrigin, PolynomialReDoSFlow::PathNode dataDestination,
  // Sink node representing the destination of data flow
  Sink destinationNode,
  // Regular expression term that may cause backtracking issues
  PolynomialBackTrackingTerm backtrackingRegex
where
  // Data flow conditions
  PolynomialReDoSFlow::flowPath(dataOrigin, dataDestination) and
  // Node mapping conditions
  destinationNode = dataDestination.getNode() and
  // Regular expression conditions
  backtrackingRegex = destinationNode.getABacktrackingTerm()
// Excluded condition: source is not URL and regex is at end of line
//   not (
//     dataOrigin.getNode().(Source).getKind() = "url" and
//     backtrackingRegex.isAtEndLine()
//   )
select 
  // Highlight the destination node and show the flow path
  destinationNode.getHighlight(), dataOrigin, dataDestination,
  // Generate warning message about potential performance issues
  "This $@ that depends on a $@ may run slow on strings " + backtrackingRegex.getPrefixMessage() +
    "with many repetitions of '" + backtrackingRegex.getPumpString() + "'.", 
  // Reference the problematic regular expression
  backtrackingRegex, "regular expression",
  // Reference the source of uncontrolled data
  dataOrigin.getNode(), "user-provided value"