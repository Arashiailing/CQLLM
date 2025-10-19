/**
 * @name Polynomial regular expression used on uncontrolled data
 * @description Identifies regular expressions that may require polynomial time
 *              to match, potentially leading to denial-of-service attacks
 *              when processing uncontrolled input data.
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
// Import specialized module for detecting polynomial-time regex vulnerabilities
import semmle.python.security.dataflow.PolynomialReDoSQuery
// Import path graph utilities for tracking data flow paths
import PolynomialReDoSFlow::PathGraph

// Identify vulnerable regex patterns applied to uncontrolled input
from
  // Source node representing uncontrolled input data
  PolynomialReDoSFlow::PathNode inputSource,
  // Sink node where regex is applied to uncontrolled data
  PolynomialReDoSFlow::PathNode regexSink,
  // Vulnerable regex usage location
  Sink vulnerableRegexUsage,
  // Regex pattern with potential exponential backtracking
  PolynomialBackTrackingTerm problematicPattern
where
  // Verify data flow path exists from source to sink
  PolynomialReDoSFlow::flowPath(inputSource, regexSink) and
  // Confirm sink node matches vulnerable regex usage
  vulnerableRegexUsage = regexSink.getNode() and
  // Extract problematic regex pattern from sink
  problematicPattern = vulnerableRegexUsage.getABacktrackingTerm()
// Disabled filter: exclude cases where source is URL and regex matches end of line
//   not (
//     inputSource.getNode().(Source).getKind() = "url" and
//     problematicPattern.isAtEndLine()
//   )
select
  // Highlight vulnerable regex usage location
  vulnerableRegexUsage.getHighlight(), inputSource, regexSink,
  // Generate warning message with performance impact details
  "This $@ that depends on a $@ may run slowly on strings " + problematicPattern.getPrefixMessage() +
    "with many repetitions of '" + problematicPattern.getPumpString() + "'.",
  // Identify the problematic regular expression
  problematicPattern, "regular expression",
  // Identify the source of uncontrolled data
  inputSource.getNode(), "user-provided value"