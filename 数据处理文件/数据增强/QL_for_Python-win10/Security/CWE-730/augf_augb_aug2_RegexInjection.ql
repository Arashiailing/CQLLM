/**
 * @name Regular expression injection vulnerability
 * @description Constructing regex patterns using unescaped user input enables injection attacks.
 *              Attackers can craft patterns causing exponential runtime (ReDoS) for specific inputs,
 *              potentially leading to denial of service.
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
  RegexInjectionFlow::PathNode taintedSource, 
  RegexInjectionFlow::PathNode vulnerableSink,
  RegexExecution regexOperation
where
  regexOperation = vulnerableSink.getNode().(Sink).getRegexExecution() and
  RegexInjectionFlow::flowPath(taintedSource, vulnerableSink)
select
  vulnerableSink.getNode(), 
  taintedSource, 
  vulnerableSink,
  "This regex pattern incorporates a $@ and is executed via $@.", 
  taintedSource.getNode(), 
  "user-controlled input", 
  regexOperation, 
  regexOperation.getName()