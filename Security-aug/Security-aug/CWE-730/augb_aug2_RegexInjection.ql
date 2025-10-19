/**
 * @name Regular expression injection vulnerability
 * @description Building regular expressions with unescaped user input can lead to injection attacks.
 *              Malicious actors may design patterns causing exponential runtime (ReDoS) on specific inputs,
 *              potentially resulting in denial of service.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/regex-injection
 * @tags security
 *       external/cwe/cwe-730
 *       external/cwe/cwe-400
 */

import python
private import semmle.python.Concepts
import semmle.python.security.dataflow.RegexInjectionQuery
import RegexInjectionFlow::PathGraph

from
  RegexInjectionFlow::PathNode sourceNode, 
  RegexInjectionFlow::PathNode sinkNode,
  RegexExecution regexExecution
where
  regexExecution = sinkNode.getNode().(Sink).getRegexExecution() and
  RegexInjectionFlow::flowPath(sourceNode, sinkNode)
select
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode,
  "This regular expression incorporates a $@ and is processed via $@.", 
  sourceNode.getNode(), 
  "user-provided value", 
  regexExecution, 
  regexExecution.getName()