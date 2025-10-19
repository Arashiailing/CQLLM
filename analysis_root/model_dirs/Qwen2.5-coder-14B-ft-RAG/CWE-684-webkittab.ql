/**
 * @name CWE-684: Incorrect Provision of Specified Functionality
 * @description This code detects Cross-Site Scripting vulnerabilities in reflected web applications.
 *              When user input is directly rendered in a web page without proper sanitization,
 *              it could enable malicious users to inject scripts into content viewed by other users.
 * @id py/reflected-cross-site-scripting
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @security-severity 6.1
 * @tags security
 *       external/cwe/cwe-079
 */

// Import core Python analysis capabilities
import python
// Import specialized module for detecting reflected cross-site scripting flaws
import semmle.python.security.dataflow.ReflectedXssQuery
// Import graph utilities for representing data flow paths
import ReflectedXssFlow::PathGraph

// Identify nodes representing user inputs and sinks where output occurs
from ReflectedXssFlow::PathNode userInputNode, ReflectedXssFlow::PathNode outputSinkNode
// Verify existence of data flow path from user input to output sink
where ReflectedXssFlow::flowPath(userInputNode, outputSinkNode)
// Report results: location of vulnerability, complete flow path, and descriptive message
select outputSinkNode.getNode(), userInputNode, outputSinkNode, 
  "Cross-site scripting vulnerability caused by a $@.", 
  userInputNode.getNode(), "user-provided value"