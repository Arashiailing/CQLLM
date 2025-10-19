/**
 * @name Reflected server-side cross-site scripting
 * @description Detects XSS vulnerabilities caused by direct output of user input
 *              to web pages without proper sanitization
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

// Import core Python analysis modules
import python

// Import experimental email XSS data flow tracking
import experimental.semmle.python.security.dataflow.EmailXss

// Import path visualization components
import EmailXssFlow::PathGraph

// Define query logic: Trace data flow from user input to dangerous output
from 
  EmailXssFlow::PathNode sourceNode,  // Represents untrusted user input
  EmailXssFlow::PathNode sinkNode     // Represents vulnerable output point
where 
  EmailXssFlow::flowPath(sourceNode, sinkNode)  // Establish data flow connection

// Generate vulnerability report with path details
select 
  sinkNode.getNode(),                // Vulnerable output location
  sourceNode,                        // Source node for path visualization
  sinkNode,                          // Sink node for path visualization
  "Cross-site scripting vulnerability due to $@.",  // Issue description
  sourceNode.getNode(),              // Source location reference
  "User-provided value"              // Source node description