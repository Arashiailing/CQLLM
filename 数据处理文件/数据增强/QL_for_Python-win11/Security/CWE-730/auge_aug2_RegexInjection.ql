/**
 * @name Regular expression injection vulnerability
 * @description Constructing regular expressions with unescaped user input enables injection attacks.
 *              Malicious patterns can cause exponential runtime (ReDoS) on specific inputs,
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
  RegexInjectionFlow::flowPath(sourceNode, sinkNode)
  and
  regexExecution = sinkNode.getNode().(Sink).getRegexExecution()
select
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode,
  "This regular expression incorporates a $@ and is processed via $@.", 
  sourceNode.getNode(), 
  "user-provided value", 
  regexExecution, 
  regexExecution.getName()