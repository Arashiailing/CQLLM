/**
 * @name Reflected server-side cross-site scripting
 * @description Identifies security flaws where untrusted user input
 *              is directly rendered in web responses without proper
 *              sanitization, enabling XSS attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @sub-severity high
 * @precision high
 * @id py/reflective-xss
 * @tags security
 *       external/cwe/cwe-079
 *       external/cwe/cwe-116
 */

// Import core Python analysis capabilities
import python
// Import specialized XSS vulnerability detection module
import semmle.python.security.dataflow.ReflectedXssQuery
// Import path visualization components for data flow
import ReflectedXssFlow::PathGraph

// Define source and sink nodes for vulnerability tracking
from ReflectedXssFlow::PathNode source, ReflectedXssFlow::PathNode sink
// Verify complete data flow path exists between source and sink
where ReflectedXssFlow::flowPath(source, sink)
// Report vulnerability with flow path details and context
select sink.getNode(), 
       source, 
       sink, 
       "Cross-site scripting vulnerability due to a $@.", 
       source.getNode(), 
       "user-provided value"