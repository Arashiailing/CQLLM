/**
 * @name Code injection
 * @description Detects code execution paths where unsanitized user input is interpreted as code,
 *              enabling arbitrary code execution by malicious actors.
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

// Import core Python analysis library
import python

// Import security dataflow module for code injection detection
import semmle.python.security.dataflow.CodeInjectionQuery

// Import path graph representation for taint flow visualization
import CodeInjectionFlow::PathGraph

// Identify code injection paths from user input to code execution
from CodeInjectionFlow::PathNode injectionSource, CodeInjectionFlow::PathNode injectionSink
where 
  // Verify existence of data flow path from source to sink
  CodeInjectionFlow::flowPath(injectionSource, injectionSink)
select 
  // Vulnerable code execution location
  injectionSink.getNode(), 
  // Taint flow path components
  injectionSource, 
  injectionSink, 
  // Security message with source reference
  "This code execution depends on a $@.", 
  injectionSource.getNode(),
  "user-provided value"