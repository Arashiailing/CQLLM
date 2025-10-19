/**
 * @name Regular expression injection vulnerability
 * @description Identifies security flaws where unvalidated user input is incorporated
 *              into regular expression patterns, enabling malicious actors to create
 *              patterns that result in exponential backtracking and denial of service.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/regex-injection
 * @tags security
 *       external/cwe/cwe-730
 *       external/cwe/cwe-400
 */

// Import Python standard library components
import python
// Import core Semmle Python language constructs
private import semmle.python.Concepts
// Import regex injection data flow analysis framework
import semmle.python.security.dataflow.RegexInjectionQuery
// Import path graph for tracking regex injection data flows
import RegexInjectionFlow::PathGraph

// Detect vulnerable regular expression execution flows
from
  RegexInjectionFlow::PathNode inputSourceNode, 
  RegexInjectionFlow::PathNode regexSinkNode,
  RegexExecution regexExecContext
where
  // Establish data flow connection between user input and regex usage
  RegexInjectionFlow::flowPath(inputSourceNode, regexSinkNode) and
  // Retrieve the regex execution context from the sink node
  regexExecContext = regexSinkNode.getNode().(Sink).getRegexExecution()
// Generate security alert with complete flow information
select regexSinkNode.getNode(), inputSourceNode, regexSinkNode,
  "This regular expression pattern incorporates a $@ and is processed by $@.", 
  inputSourceNode.getNode(), "user-controlled input", 
  regexExecContext, regexExecContext.getName()