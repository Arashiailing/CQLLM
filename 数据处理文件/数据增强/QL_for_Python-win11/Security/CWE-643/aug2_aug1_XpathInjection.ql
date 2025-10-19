/**
 * @name XPath injection from user-controlled input
 * @description Identifies XPath query construction using untrusted user input,
 *              enabling injection of malicious XPath expressions.
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

// Trace data flow from untrusted sources to XPath sinks
from XpathInjectionFlow::PathNode maliciousSource, XpathInjectionFlow::PathNode injectionSink
where XpathInjectionFlow::flowPath(maliciousSource, injectionSink)
select injectionSink.getNode(), 
       maliciousSource, 
       injectionSink, 
       "XPath expression incorporates a $@.", 
       maliciousSource.getNode(), 
       "user-controlled input"