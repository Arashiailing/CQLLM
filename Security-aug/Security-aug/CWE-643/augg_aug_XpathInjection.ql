/**
 * @name XPath query built from user-controlled sources
 * @description Detects XPath queries constructed from untrusted input,
 *              which could allow injection of malicious XPath expressions.
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

// Identify data flow paths from untrusted sources to XPath sinks
from XpathInjectionFlow::PathNode untrustedSource, XpathInjectionFlow::PathNode xpathSink
// Trace complete data flow paths from user input to XPath execution
where XpathInjectionFlow::flowPath(untrustedSource, xpathSink)
// Report findings with sink location, source details, and flow path
select xpathSink.getNode(), 
       untrustedSource, 
       xpathSink, 
       "XPath expression incorporates a $@.", 
       untrustedSource.getNode(),
       "user-controlled input"