/**
 * @name Code injection vulnerability
 * @description Detects execution paths where unvalidated user input is passed to code evaluation,
 *              enabling attackers to execute arbitrary commands.
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

// Core Python language analysis framework
import python

// Dataflow tracking for code injection vulnerabilities
import semmle.python.security.dataflow.CodeInjectionQuery

// Path visualization for taint propagation
import CodeInjectionFlow::PathGraph

// Identify tainted data flow from untrusted sources to code execution points
from 
  CodeInjectionFlow::PathNode untrustedSource, 
  CodeInjectionFlow::PathNode codeExecutionSink
where 
  // Validate existence of complete taint propagation path
  CodeInjectionFlow::flowPath(untrustedSource, codeExecutionSink)
select 
  // Location of vulnerable code execution
  codeExecutionSink.getNode(), 
  // Taint flow source and sink nodes
  untrustedSource, 
  codeExecutionSink, 
  // Security alert message with source reference
  "Code execution relies on $@.", 
  untrustedSource.getNode(),
  "unvalidated user input"