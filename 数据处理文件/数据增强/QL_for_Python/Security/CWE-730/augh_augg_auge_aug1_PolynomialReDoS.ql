/**
 * @name Polynomial regular expression used on uncontrolled data
 * @description Detects regular expressions exhibiting polynomial-time complexity
 *              that could result in denial-of-service vulnerabilities.
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

// Import core Python analysis framework
import python
// Import specialized module for regex pattern backtracking vulnerability detection
import semmle.python.security.dataflow.PolynomialReDoSQuery
// Import path visualization utilities for security data flow analysis
import PolynomialReDoSFlow::PathGraph

from
  // Define source and destination nodes for tracking untrusted input flow
  PolynomialReDoSFlow::PathNode untrustedDataSource, PolynomialReDoSFlow::PathNode regexUsagePoint,
  // Identify the specific sink where regex is applied to uncontrolled input
  Sink regexSinkLocation,
  // Extract the regex pattern component causing polynomial-time backtracking
  PolynomialBackTrackingTerm problematicRegexPattern
where
  // Establish complete data flow path from untrusted source to regex usage
  PolynomialReDoSFlow::flowPath(untrustedDataSource, regexUsagePoint) and
  // Connect the destination node to the actual regex sink implementation
  regexSinkLocation = regexUsagePoint.getNode() and
  // Extract the problematic regex pattern term from the vulnerable sink
  problematicRegexPattern = regexSinkLocation.getABacktrackingTerm()
// Disabled filter: exclude URL sources with end-of-line matching regex
//   not (
//     untrustedDataSource.getNode().(Source).getKind() = "url" and
//     problematicRegexPattern.isAtEndLine()
//   )
select
  // Output visualization components: vulnerable regex location and data flow endpoints
  regexSinkLocation.getHighlight(), untrustedDataSource, regexUsagePoint,
  // Generate comprehensive vulnerability description with contextual information
  "This $@ that uses a $@ may suffer from performance degradation " + 
  "when processing strings " + problematicRegexPattern.getPrefixMessage() +
  "containing multiple repetitions of '" + problematicRegexPattern.getPumpString() + "'.",
  // Reference the problematic regex pattern for highlighting purposes
  problematicRegexPattern, "regular expression",
  // Reference the untrusted data source for tracking purposes
  untrustedDataSource.getNode(), "user-provided value"