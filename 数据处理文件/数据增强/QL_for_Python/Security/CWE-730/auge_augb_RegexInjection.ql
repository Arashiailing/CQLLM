/**
 * @name Regular expression injection
 * @description Detects when unescaped user input is used in regular expressions,
 *              allowing attackers to craft patterns causing exponential runtime.
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
  RegexInjectionFlow::PathNode sourceNode, 
  RegexInjectionFlow::PathNode sinkPathNode,
  RegexExecution regexExecution
// Validate data flow path and regex execution context
where
  // Verify data flow from source to sink
  RegexInjectionFlow::flowPath(sourceNode, sinkPathNode) and
  // Extract regex execution context from sink
  regexExecution = sinkPathNode.getNode().(Sink).getRegexExecution()
// Generate security report with flow details
select sinkPathNode.getNode(), sourceNode, sinkPathNode,
  "This regular expression depends on a $@ and is executed by $@.", 
  sourceNode.getNode(), "user-provided value", 
  regexExecution, regexExecution.getName()