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

// Import necessary modules for Python code analysis
import python
// Import specialized module for detecting regex patterns with polynomial backtracking vulnerabilities
import semmle.python.security.dataflow.PolynomialReDoSQuery
// Import path graph utilities for visualizing data flow paths in security analysis
import PolynomialReDoSFlow::PathGraph

from
  // Define data flow origin and destination nodes for tracking untrusted input
  PolynomialReDoSFlow::PathNode dataOrigin, PolynomialReDoSFlow::PathNode dataDestination,
  // Identify the specific sink location where regex is applied to uncontrolled data
  Sink vulnerableRegexSink,
  // Extract the regex pattern component that causes polynomial-time backtracking
  PolynomialBackTrackingTerm vulnerableRegexPattern
where
  // Establish complete data flow path from untrusted source to regex usage
  PolynomialReDoSFlow::flowPath(dataOrigin, dataDestination) and
  // Map the destination node to the actual regex sink implementation
  vulnerableRegexSink = dataDestination.getNode() and
  // Retrieve the problematic regex pattern term from the vulnerable sink
  vulnerableRegexPattern = vulnerableRegexSink.getABacktrackingTerm()
// Disabled filter: exclude URL sources with end-of-line matching regex
//   not (
//     dataOrigin.getNode().(Source).getKind() = "url" and
//     vulnerableRegexPattern.isAtEndLine()
//   )
select
  // Output visualization elements: vulnerable regex location and data flow endpoints
  vulnerableRegexSink.getHighlight(), dataOrigin, dataDestination,
  // Generate detailed vulnerability description with context
  "This $@ that uses a $@ may experience performance degradation " + 
  "when processing strings " + vulnerableRegexPattern.getPrefixMessage() +
  "containing multiple repetitions of '" + vulnerableRegexPattern.getPumpString() + "'.",
  // Reference the vulnerable regex pattern for highlighting
  vulnerableRegexPattern, "regular expression",
  // Reference the untrusted data source for tracking
  dataOrigin.getNode(), "user-provided value"