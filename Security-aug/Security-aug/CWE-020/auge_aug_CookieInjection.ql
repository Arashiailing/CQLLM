/**
 * @name Cookie construction with unvalidated user input
 * @description Detects when HTTP cookies are constructed using user-supplied input without proper validation,
 *              which could lead to Cookie Poisoning attacks where an attacker manipulates cookie values
 *              to bypass security controls, perform session fixation, or execute other malicious activities.
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

// Define variables representing the start and end points of the data flow
from CookieInjectionFlow::PathNode userInputNode, CookieInjectionFlow::PathNode cookieConstructionNode

// Check if there exists a data flow path from user input to cookie construction
where CookieInjectionFlow::flowPath(userInputNode, cookieConstructionNode)

// Output the detection results including the sink node, source node, path information,
// and a security description highlighting the vulnerability
select cookieConstructionNode.getNode(), userInputNode, cookieConstructionNode, 
       "Cookie is constructed from a $@.", userInputNode.getNode(), 
       "user-supplied input"