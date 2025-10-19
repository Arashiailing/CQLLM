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

// Identify vulnerable regex patterns applied to uncontrolled data
from
  // Starting point of untrusted input in the data flow
  PolynomialReDoSFlow::PathNode inputSource, 
  // Endpoint where data reaches regex processing
  PolynomialReDoSFlow::PathNode regexEndpoint,
  // Location where regex is executed
  Sink regexExecutionSite,
  // Regex pattern with potential for exponential backtracking
  PolynomialBackTrackingTerm vulnerableRegexPattern
where
  // Verify complete data flow path exists from source to sink
  PolynomialReDoSFlow::flowPath(inputSource, regexEndpoint) and
  // Connect endpoint to actual regex execution site
  regexExecutionSite = regexEndpoint.getNode() and
  // Extract vulnerable regex pattern from execution site
  vulnerableRegexPattern = regexExecutionSite.getABacktrackingTerm()
// Disabled filter: Exclude URL sources with end-of-line patterns
//   not (
//     inputSource.getNode().(Source).getKind() = "url" and
//     vulnerableRegexPattern.isAtEndLine()
//   )
select
  // Highlight vulnerable regex usage location
  regexExecutionSite.getHighlight(), inputSource, regexEndpoint,
  // Generate vulnerability description with technical details
  "This $@ processing a $@ may exhibit slow performance " + vulnerableRegexPattern.getPrefixMessage() +
    "when encountering repeated instances of '" + vulnerableRegexPattern.getPumpString() + "'.",
  // Identify the problematic regex pattern
  vulnerableRegexPattern, "regular expression",
  // Identify the uncontrolled data source
  inputSource.getNode(), "user-provided input"