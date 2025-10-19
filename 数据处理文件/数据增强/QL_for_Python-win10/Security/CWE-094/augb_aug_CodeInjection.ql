/**
 * @name Code injection
 * @description Identifies execution paths where unvalidated user input is evaluated as code,
 *              allowing attackers to execute arbitrary commands.
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

// Core Python analysis framework
import python

// Security dataflow analysis for code injection detection
import semmle.python.security.dataflow.CodeInjectionQuery

// Path graph visualization for taint tracking
import CodeInjectionFlow::PathGraph

// Detect tainted data flow from user input to code execution
from 
  CodeInjectionFlow::PathNode taintedSource, 
  CodeInjectionFlow::PathNode executionSink
where 
  // Verify taint propagation path exists
  CodeInjectionFlow::flowPath(taintedSource, executionSink)
select 
  // Vulnerable code execution point
  executionSink.getNode(), 
  // Source and sink of taint flow
  taintedSource, 
  executionSink, 
  // Security alert with source reference
  "Code execution depends on $@.", 
  taintedSource.getNode(),
  "untrusted user input"