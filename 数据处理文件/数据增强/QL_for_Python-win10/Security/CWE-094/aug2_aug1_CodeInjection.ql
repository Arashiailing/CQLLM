/**
 * @name Code injection
 * @description Detects execution paths where unsanitized user input is interpreted as code,
 *              enabling attackers to execute arbitrary code.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.3
 * @sub-severity high
 * @precision high
 * @id py/code-injection
 * @tags security
 *       external/cwe/cwe-094
 *       external/cwe/cwe-095
 *       external/cwe/cwe-116
 */

// Core Python analysis libraries
import python

// Security dataflow modules for code injection detection
import semmle.python.security.dataflow.CodeInjectionQuery

// Path graph representation for taint flow analysis
import CodeInjectionFlow::PathGraph

// Identify code injection paths through tainted data flow
from CodeInjectionFlow::PathNode taintedSource, CodeInjectionFlow::PathNode codeExecutionSink
where 
  // Verify complete taint propagation from source to sink
  CodeInjectionFlow::flowPath(taintedSource, codeExecutionSink)
select 
  // Vulnerability execution point (sink)
  codeExecutionSink.getNode(), 
  // Flow path visualization components
  taintedSource, 
  codeExecutionSink, 
  // Security message with source context
  "This code execution depends on a $@.", 
  taintedSource.getNode(),
  "user-provided value"