/**
 * @name Regular expression injection
 * @description Detects when user input is incorporated into regular expressions without proper escaping,
 *              enabling attackers to inject patterns that cause exponential time complexity on certain inputs.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/regex-injection
 * @tags security
 *       external/cwe/cwe-730
 *       external/cwe/cwe-400
 */

// Import Python standard library
import python
// Import Semmle Python core concepts
private import semmle.python.Concepts
// Import regex injection security data flow module
import semmle.python.security.dataflow.RegexInjectionQuery
// Import path graph for regex injection flow analysis
import RegexInjectionFlow::PathGraph

// Identify vulnerable regex execution paths
from
  RegexInjectionFlow::PathNode sourceNode, RegexInjectionFlow::PathNode targetNode,
  RegexExecution regexExecution
// Validate data flow path and regex execution context
where
  RegexInjectionFlow::flowPath(sourceNode, targetNode) and
  regexExecution = targetNode.getNode().(Sink).getRegexExecution()
// Generate security report with flow details
select targetNode.getNode(), sourceNode, targetNode,
  "This regular expression depends on a $@ and is executed by $@.", sourceNode.getNode(),
  "user-provided value", regexExecution, regexExecution.getName()