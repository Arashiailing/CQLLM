/**
 * @name Regular expression injection
 * @description Identifies instances where unescaped user-supplied data is incorporated
 *              into regular expression patterns, enabling attackers to create malicious
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

// Fundamental Python language support
import python
// Core Semmle Python security concept definitions
private import semmle.python.Concepts
// Data flow tracking for regex injection vulnerabilities
import semmle.python.security.dataflow.RegexInjectionQuery
// Path visualization framework for taint flow analysis
import RegexInjectionFlow::PathGraph

// Define sources of untrusted input and vulnerable regex usage points
from 
  RegexInjectionFlow::PathNode untrustedInput, 
  RegexInjectionFlow::PathNode regexSink,
  RegexExecution patternExecution
// Establish taint flow relationship and connect to regex execution
where
  // Verify data flows from untrusted source to regex sink
  RegexInjectionFlow::flowPath(untrustedInput, regexSink) and
  // Link the sink node to actual regex pattern execution
  patternExecution = regexSink.getNode().(Sink).getRegexExecution()
// Output security finding with complete taint flow information
select regexSink.getNode(), untrustedInput, regexSink,
  "This regular expression pattern incorporates unescaped $@ and is executed via $@.", 
  untrustedInput.getNode(), "user-controlled input", 
  patternExecution, patternExecution.getName()