/**
 * @name Code injection
 * @description Identifies execution paths where unvalidated user input is executed as code,
 *              allowing attackers to run arbitrary commands.
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

// Security dataflow modules for detecting code injection vulnerabilities
import semmle.python.security.dataflow.CodeInjectionQuery

// Path graph representation for analyzing taint propagation
import CodeInjectionFlow::PathGraph

// Trace tainted data from entry points to code execution sinks
from CodeInjectionFlow::PathNode taintedSource, CodeInjectionFlow::PathNode vulnerableSink
where 
  // Ensure complete taint flow between source and sink
  CodeInjectionFlow::flowPath(taintedSource, vulnerableSink)
select 
  // Vulnerable code execution location
  vulnerableSink.getNode(), 
  // Taint flow visualization components
  taintedSource, 
  vulnerableSink, 
  // Security alert message with source context
  "This code execution relies on a $@.", 
  taintedSource.getNode(),
  "user-controlled input"