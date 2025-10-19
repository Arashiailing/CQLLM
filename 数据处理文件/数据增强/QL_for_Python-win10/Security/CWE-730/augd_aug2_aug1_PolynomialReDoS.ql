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

// Define data flow path components with enhanced variable naming
from
  // Source node representing uncontrolled input (renamed from sourceNode)
  PolynomialReDoSFlow::PathNode uncontrolledInputNode, 
  // Terminal node in data flow path (renamed from terminalNode)
  PolynomialReDoSFlow::PathNode regexUsageNode,
  // Sink where regex is applied (renamed from regexSink)
  Sink regexApplicationSink,
  // Vulnerable regex pattern (renamed from vulnerableRegex)
  PolynomialBackTrackingTerm vulnerableRegexPattern
where
  // Verify complete data flow path exists from uncontrolled input to regex usage
  PolynomialReDoSFlow::flowPath(uncontrolledInputNode, regexUsageNode) and
  
  // Map terminal node to regex application sink and extract vulnerable pattern
  regexApplicationSink = regexUsageNode.getNode() and
  vulnerableRegexPattern = regexApplicationSink.getABacktrackingTerm()
  
  // Disabled filter: Exclude URL sources with end-of-line patterns
  //   not (
  //     uncontrolledInputNode.getNode().(Source).getKind() = "url" and
  //     vulnerableRegexPattern.isAtEndLine()
  //   )
select
  // Highlight vulnerable code locations with enhanced variable references
  regexApplicationSink.getHighlight(), uncontrolledInputNode, regexUsageNode,
  // Generate vulnerability description using new variable names
  "This $@ processing a $@ may exhibit slow performance " + vulnerableRegexPattern.getPrefixMessage() +
    "when encountering repeated instances of '" + vulnerableRegexPattern.getPumpString() + "'.",
  // Identify vulnerable regex pattern
  vulnerableRegexPattern, "regular expression",
  // Identify uncontrolled data source
  uncontrolledInputNode.getNode(), "user-provided input"