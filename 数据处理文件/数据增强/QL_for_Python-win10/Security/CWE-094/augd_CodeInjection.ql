/**
 * @name Code injection
 * @description Detects potential code injection vulnerabilities where unsanitized user input 
 *              is interpreted as code, enabling arbitrary code execution by attackers.
 *              This query traces data flow from user-controlled sources to dangerous code execution sinks.
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

// Import the core Python library for code analysis and AST traversal
import python

// Import the specialized data flow module for detecting code injection vulnerabilities
import semmle.python.security.dataflow.CodeInjectionQuery

// Import the PathGraph class which provides methods to analyze and visualize data flow paths
import CodeInjectionFlow::PathGraph

// Define a query to identify code injection vulnerabilities by tracking data flow
// from user-controlled input sources to potentially dangerous code execution sinks
from CodeInjectionFlow::PathNode injectionSource, CodeInjectionFlow::PathNode injectionSink
// Establish the condition: there must be a valid data flow path from the source to the sink
where CodeInjectionFlow::flowPath(injectionSource, injectionSink)
// Select the vulnerable code execution point, the source of user input, the sink,
// a descriptive message about the vulnerability, and a label for the source
select injectionSink.getNode(), injectionSource, injectionSink, 
  "This code execution depends on a $@.", injectionSource.getNode(),
  "user-provided value"