/**
 * @name Regular expression injection
 * @description User input should not be used in regular expressions without first being escaped,
 *              otherwise a malicious user may be able to inject an expression that could require
 *              exponential time on certain inputs.
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
  RegexInjectionFlow::PathNode src, RegexInjectionFlow::PathNode sinkNode,
  RegexExecution regexExec
// Validate data flow path and regex execution context
where
  RegexInjectionFlow::flowPath(src, sinkNode) and
  regexExec = sinkNode.getNode().(Sink).getRegexExecution()
// Generate security report with flow details
select sinkNode.getNode(), src, sinkNode,
  "This regular expression depends on a $@ and is executed by $@.", src.getNode(),
  "user-provided value", regexExec, regexExec.getName()