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

// Import core Python analysis modules
import python
// Import specialized module for polynomial complexity regex detection
import semmle.python.security.dataflow.PolynomialReDoSQuery
// Import path analysis infrastructure for vulnerability tracking
import PolynomialReDoSFlow::PathGraph

from
  // Identify regex patterns vulnerable to exponential backtracking
  PolynomialBackTrackingTerm vulnerablePattern,
  // Locate uncontrolled input data sources
  PolynomialReDoSFlow::PathNode uncontrolledDataSource,
  // Pinpoint actual regex usage locations in code
  PolynomialReDoSFlow::PathNode regexUsageLocation,
  // Identify sink entities containing regex operations
  Sink regexSinkEntity
where
  // Establish data flow path from source to regex usage
  PolynomialReDoSFlow::flowPath(uncontrolledDataSource, regexUsageLocation) and
  // Map sink entity to its corresponding usage location
  regexSinkEntity = regexUsageLocation.getNode() and
  // Extract vulnerable regex pattern from sink entity
  vulnerablePattern = regexSinkEntity.getABacktrackingTerm()
  // Original excluded condition (preserved as comment):
  //   not (
  //     uncontrolledDataSource.getNode().(Source).getKind() = "url" and
  //     vulnerablePattern.isAtEndLine()
  //   )
select 
  // Highlight vulnerable regex location in code
  regexSinkEntity.getHighlight(), 
  uncontrolledDataSource, 
  regexUsageLocation,
  // Construct detailed vulnerability warning message
  "This $@ that depends on a $@ may run slow on strings " + vulnerablePattern.getPrefixMessage() +
    "with many repetitions of '" + vulnerablePattern.getPumpString() + "'.", 
  // Reference vulnerable regex pattern for reporting
  vulnerablePattern, "regular expression",
  // Reference source of uncontrolled input data
  uncontrolledDataSource.getNode(), "user-provided value"