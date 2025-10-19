/**
 * @name Regular expression injection
 * @description Detects when user-supplied input is directly used in regular expressions
 *              without proper escaping, enabling attackers to craft malicious regex patterns
 *              that cause exponential backtracking and denial-of-service.
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
// Internal Semmle Python analysis concepts
private import semmle.python.Concepts
// Regex injection security dataflow analysis
import semmle.python.security.dataflow.RegexInjectionQuery
// Path graph for taint flow visualization
import RegexInjectionFlow::PathGraph

// Identify vulnerable regex patterns through dataflow analysis
from
  RegexInjectionFlow::PathNode taintedInput, RegexInjectionFlow::PathNode vulnerableRegex,
  RegexExecution regexInstance
where
  // Verify complete taint propagation from source to sink
  RegexInjectionFlow::flowPath(taintedInput, vulnerableRegex) and
  // Associate sink node with its regex execution context
  regexInstance = vulnerableRegex.getNode().(Sink).getRegexExecution()
// Report security findings with contextual information
select vulnerableRegex.getNode(), taintedInput, vulnerableRegex,
  "This regex pattern incorporates a $@ and is executed by $@.", 
  taintedInput.getNode(), "user-provided value", 
  regexInstance, regexInstance.getName()