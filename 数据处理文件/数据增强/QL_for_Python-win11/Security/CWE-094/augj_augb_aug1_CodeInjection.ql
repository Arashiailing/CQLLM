/**
 * @name Code injection
 * @description Detects potential code injection vulnerabilities where unvalidated user input
 *              is processed as executable code, potentially enabling remote code execution.
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

// Import fundamental Python language analysis capabilities
import python

// Import specialized security analysis module for code injection detection
import semmle.python.security.dataflow.CodeInjectionQuery

// Import path graph utilities for tracking data flow propagation
import CodeInjectionFlow::PathGraph

// Identify paths where untrusted input flows to code execution points
from CodeInjectionFlow::PathNode untrustedInputSource, CodeInjectionFlow::PathNode codeExecutionSink
where 
  // Verify that a complete data flow path exists from source to sink
  CodeInjectionFlow::flowPath(untrustedInputSource, codeExecutionSink)
select 
  // The vulnerable code execution location
  codeExecutionSink.getNode(), 
  // Source and sink nodes for path visualization
  untrustedInputSource, 
  codeExecutionSink, 
  // Security warning message with source reference
  "This code execution depends on a $@.", 
  untrustedInputSource.getNode(),
  "user-controlled input"