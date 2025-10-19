/**
 * @name Code injection vulnerability detection
 * @description Identifies potential code injection risks where unsanitized user input 
 *              gets executed as code, allowing attackers to run arbitrary commands.
 *              This analysis tracks data flow from user-controlled sources to critical code execution points.
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

// Import core Python analysis capabilities for AST processing
import python

// Import specialized data flow tracking for code injection detection
import semmle.python.security.dataflow.CodeInjectionQuery

// Import path visualization utilities for data flow analysis
import CodeInjectionFlow::PathGraph

// Define vulnerability detection logic by tracing data paths
from CodeInjectionFlow::PathNode userInputSource, CodeInjectionFlow::PathNode codeExecutionSink
// Validate data flow connection between source and sink
where CodeInjectionFlow::flowPath(userInputSource, codeExecutionSink)
// Output vulnerability details with contextual information
select codeExecutionSink.getNode(), userInputSource, codeExecutionSink,
  "This code execution depends on a $@.", userInputSource.getNode(),
  "user-provided value"