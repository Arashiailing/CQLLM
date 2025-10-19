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

// Import necessary Python libraries
import python
// Import the PolynomialReDoSQuery module for detecting polynomial complexity regex issues
import semmle.python.security.dataflow.PolynomialReDoSQuery
// Import PathGraph class for path graph analysis
import PolynomialReDoSFlow::PathGraph

from
  // Define the vulnerable regular expression pattern that can cause exponential backtracking
  PolynomialBackTrackingTerm vulnerableRegex,
  // Define the source node representing uncontrolled input data
  PolynomialReDoSFlow::PathNode sourceNode,
  // Define the sink path node where the regex is used
  PolynomialReDoSFlow::PathNode sinkPathNode,
  // Define the sink entity that contains the actual regex usage
  Sink sinkEntity
where
  // Verify there is a data flow path from source to sink
  PolynomialReDoSFlow::flowPath(sourceNode, sinkPathNode) and
  // Ensure the sink entity matches our sink path node
  sinkEntity = sinkPathNode.getNode() and
  // Extract the vulnerable regex pattern from the sink entity
  vulnerableRegex = sinkEntity.getABacktrackingTerm()
// Note: The following commented-out condition was in the original query
//   not (
//     sourceNode.getNode().(Source).getKind() = "url" and
//     vulnerableRegex.isAtEndLine()
//   )
select 
  // Highlight the vulnerable regex location in the code
  sinkEntity.getHighlight(), sourceNode, sinkPathNode,
  // Generate a descriptive warning message about the potential performance issue
  "This $@ that depends on a $@ may run slow on strings " + vulnerableRegex.getPrefixMessage() +
    "with many repetitions of '" + vulnerableRegex.getPumpString() + "'.", 
  // Reference the vulnerable regex pattern for reporting
  vulnerableRegex, "regular expression",
  // Reference the source of uncontrolled data for reporting
  sourceNode.getNode(), "user-provided value"