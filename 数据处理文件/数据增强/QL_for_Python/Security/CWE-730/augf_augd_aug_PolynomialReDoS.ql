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

// Import core Python analysis modules for general code analysis
import python
// Import specialized module for detecting polynomial complexity regex patterns
import semmle.python.security.dataflow.PolynomialReDoSQuery
// Import path analysis infrastructure to track data flow paths
import PolynomialReDoSFlow::PathGraph

from
  // Identify regex patterns that can cause exponential backtracking
  PolynomialBackTrackingTerm vulnerableRegexPattern,
  // Locate sources of uncontrolled input data that could be used in regex operations
  PolynomialReDoSFlow::PathNode uncontrolledInputSource,
  // Pinpoint exact locations where regex operations are performed in the code
  PolynomialReDoSFlow::PathNode regexOperationSite,
  // Identify sink entities that represent the regex operations
  Sink regexOperationSink
where
  // Trace data flow from uncontrolled input source to regex operation site
  PolynomialReDoSFlow::flowPath(uncontrolledInputSource, regexOperationSite)
  and
  // Connect the regex operation sink to its usage location and extract the vulnerable pattern
  (
    // Map the sink entity to its corresponding usage location
    regexOperationSink = regexOperationSite.getNode()
    and
    // Extract the vulnerable regex pattern from the sink entity
    vulnerableRegexPattern = regexOperationSink.getABacktrackingTerm()
  )
  // Original excluded condition (preserved as comment):
  //   not (
  //     uncontrolledInputSource.getNode().(Source).getKind() = "url" and
  //     vulnerableRegexPattern.isAtEndLine()
  //   )
select 
  // Highlight the vulnerable regex location in the source code
  regexOperationSink.getHighlight(), 
  uncontrolledInputSource, 
  regexOperationSite,
  // Generate a detailed vulnerability warning message
  "This $@ that depends on a $@ may run slow on strings " + vulnerableRegexPattern.getPrefixMessage() +
    "with many repetitions of '" + vulnerableRegexPattern.getPumpString() + "'.", 
  // Reference the vulnerable regex pattern for reporting purposes
  vulnerableRegexPattern, "regular expression",
  // Reference the source of the uncontrolled input data
  uncontrolledInputSource.getNode(), "user-provided value"