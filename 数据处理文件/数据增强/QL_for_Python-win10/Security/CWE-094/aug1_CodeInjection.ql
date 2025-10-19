/**
 * @name Code injection
 * @description Detects code execution paths where unsanitized user input is interpreted as code,
 *              enabling arbitrary code execution by attackers.
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
from CodeInjectionFlow::PathNode injectionSource, CodeInjectionFlow::PathNode injectionSink
where 
  // Verify complete taint propagation from source to sink
  CodeInjectionFlow::flowPath(injectionSource, injectionSink)
select 
  // Vulnerability execution point (sink)
  injectionSink.getNode(), 
  // Flow path visualization components
  injectionSource, 
  injectionSink, 
  // Security message with source context
  "This code execution depends on a $@.", 
  injectionSource.getNode(),
  "user-provided value"