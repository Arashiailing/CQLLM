/**
 * @name Code injection
 * @description Identifies code execution paths where unvalidated user input is directly interpreted as code,
 *              potentially enabling arbitrary code execution by attackers.
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

// Import core Python analysis framework
import python

// Import security dataflow module for detecting code injection vulnerabilities
import semmle.python.security.dataflow.CodeInjectionQuery

// Import path graph utilities for visualizing taint propagation
import CodeInjectionFlow::PathGraph

// Detect code injection flows from untrusted input to code execution
from CodeInjectionFlow::PathNode sourceNode, CodeInjectionFlow::PathNode sinkNode
where 
  // Verify taint propagation path exists between source and sink
  CodeInjectionFlow::flowPath(sourceNode, sinkNode)
select 
  // Vulnerable code execution point
  sinkNode.getNode(), 
  // Taint flow path components
  sourceNode, 
  sinkNode, 
  // Security alert message with source reference
  "This code execution depends on a $@.", 
  sourceNode.getNode(),
  "user-provided value"