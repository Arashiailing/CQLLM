/**
 * @name Cookie construction with unvalidated user input
 * @description Identifies HTTP cookies created using unvalidated user input,
 *              potentially enabling Cookie Poisoning attacks where attackers
 *              manipulate cookie values to bypass security controls, perform
 *              session fixation, or execute other malicious activities.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Import base Python code analysis library
import python

// Import specialized module for Cookie Injection security analysis
import semmle.python.security.dataflow.CookieInjectionQuery

// Import data flow path visualization utilities
import CookieInjectionFlow::PathGraph

// Define source and sink nodes representing data flow endpoints
from CookieInjectionFlow::PathNode sourceNode, CookieInjectionFlow::PathNode sinkNode

// Verify data flow path exists from user input to cookie construction
where CookieInjectionFlow::flowPath(sourceNode, sinkNode)

// Output results including sink node, source node, path details,
// and vulnerability description
select sinkNode.getNode(), sourceNode, sinkNode, 
       "Cookie is constructed from a $@.", sourceNode.getNode(), 
       "user-supplied input"