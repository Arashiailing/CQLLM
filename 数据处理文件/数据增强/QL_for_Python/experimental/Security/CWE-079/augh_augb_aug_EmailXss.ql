/**
 * @name Reflected server-side cross-site scripting
 * @description Identifies security vulnerabilities where untrusted user input
 *              is directly reflected in web responses without proper sanitization,
 *              potentially allowing attackers to execute malicious scripts in victims' browsers.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 2.9
 * @sub-severity high
 * @id py/reflective-xss-email
 * @tags security
 *       experimental
 *       external/cwe/cwe-079
 *       external/cwe/cwe-116
 */

// Core Python analysis module import
import python

// Experimental email XSS data flow analysis module
import experimental.semmle.python.security.dataflow.EmailXss

// Path graph visualization component for tracking data flows
import EmailXssFlow::PathGraph

// Define query logic to track untrusted data flow from input sources to output sinks
// This identifies potential XSS vulnerabilities in email-related functionality
from EmailXssFlow::PathNode inputNode, EmailXssFlow::PathNode outputNode
where EmailXssFlow::flowPath(inputNode, outputNode)

// Generate vulnerability report with source and sink information
select outputNode.getNode(), 
       inputNode, 
       outputNode, 
       "Cross-site scripting vulnerability caused by $@.",
       inputNode.getNode(), 
       "User-provided value"