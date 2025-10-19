/**
 * @name Regular expression injection vulnerability
 * @description Constructing regular expressions using unescaped user input may allow injection attacks.
 *              Attackers can craft patterns that cause exponential runtime (ReDoS) on specific inputs,
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
  RegexInjectionFlow::PathNode inputOrigin, 
  RegexInjectionFlow::PathNode injectionTarget,
  RegexExecution patternExecution
where
  RegexInjectionFlow::flowPath(inputOrigin, injectionTarget) and
  patternExecution = injectionTarget.getNode().(Sink).getRegexExecution()
select
  injectionTarget.getNode(), 
  inputOrigin, 
  injectionTarget,
  "This regular expression incorporates a $@ and is processed via $@.", 
  inputOrigin.getNode(), 
  "user-provided value", 
  patternExecution, 
  patternExecution.getName()