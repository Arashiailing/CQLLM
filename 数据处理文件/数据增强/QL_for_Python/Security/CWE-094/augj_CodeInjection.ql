/**
 * @name Code injection
 * @description Execution of unsanitized user-provided input as code enables attackers to perform
 *              arbitrary code execution.
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

// Import Python language analysis library
import python

// Import CodeQL security dataflow module for code injection analysis
import semmle.python.security.dataflow.CodeInjectionQuery

// Import PathGraph class representing vulnerability propagation paths
import CodeInjectionFlow::PathGraph

// Define query identifying code injection vulnerability paths
from CodeInjectionFlow::PathNode injectionSource, CodeInjectionFlow::PathNode injectionSink
where 
  // Condition: Verify data flow path exists from source to sink
  CodeInjectionFlow::flowPath(injectionSource, injectionSink)
select 
  // Output sink location, source-to-sink path, and vulnerability description
  injectionSink.getNode(), 
  injectionSource, 
  injectionSink, 
  "This code execution depends on a $@.", 
  injectionSource.getNode(),
  "user-provided value"