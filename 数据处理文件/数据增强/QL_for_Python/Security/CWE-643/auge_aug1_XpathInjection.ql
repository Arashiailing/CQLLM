/**
 * @name XPath injection vulnerability from user input
 * @description Identifies XPath queries constructed with untrusted user input,
 *              enabling injection of malicious XPath syntax.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @precision high
 * @id py/xpath-injection
 * @tags security
 *       external/cwe/cwe-643
 */

import python
import semmle.python.security.dataflow.XpathInjectionQuery
import XpathInjectionFlow::PathGraph

// Detect data flow paths from user input to XPath query construction
from XpathInjectionFlow::PathNode maliciousInputSource, XpathInjectionFlow::PathNode xpathSinkNode
where XpathInjectionFlow::flowPath(maliciousInputSource, xpathSinkNode)
select xpathSinkNode.getNode(), 
       maliciousInputSource, 
       xpathSinkNode, 
       "XPath expression incorporates $@.", 
       maliciousInputSource.getNode(), 
       "untrusted user input"