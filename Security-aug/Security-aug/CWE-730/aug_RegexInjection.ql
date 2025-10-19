/**
 * @name Regular expression injection
 * @description Detects unescaped user input in regular expressions, which allows attackers
 *              to craft malicious patterns causing exponential processing time.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/regex-injection
 * @tags security
 *       external/cwe/cwe-730
 *       external/cwe/cwe-400
 */

// Core Python language imports
import python
// Internal Semmle Python conceptual models
private import semmle.python.Concepts
// Regex injection security data flow definitions
import semmle.python.security.dataflow.RegexInjectionQuery
// Path graph for taint flow visualization
import RegexInjectionFlow::PathGraph

// Identify vulnerable regex execution paths
from 
  RegexInjectionFlow::PathNode taintedInput, RegexInjectionFlow::PathNode vulnerableSink,
  RegexExecution regexInstance
// Validate taint flow connection to regex execution
where
  RegexInjectionFlow::flowPath(taintedInput, vulnerableSink) and
  regexInstance = vulnerableSink.getNode().(Sink).getRegexExecution()
// Generate security finding with taint path details
select vulnerableSink.getNode(), taintedInput, vulnerableSink,
  "This regular expression incorporates unescaped $@ and is executed via $@.", 
  taintedInput.getNode(), "user-controlled input", 
  regexInstance, regexInstance.getName()