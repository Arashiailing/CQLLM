/**
 * @name XPath query built from user-controlled sources
 * @description Building a XPath query from user-controlled sources is vulnerable to insertion of
 *              malicious Xpath code by the user.
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

// Define data flow nodes representing vulnerability sources and sinks
from XpathInjectionFlow::PathNode taintedSource, XpathInjectionFlow::PathNode vulnerableSink
// Identify complete data flow paths from user-controlled sources to XPath sinks
where XpathInjectionFlow::flowPath(taintedSource, vulnerableSink)
// Report results with sink location, source details, and path information
select vulnerableSink.getNode(), 
       taintedSource, 
       vulnerableSink, 
       "XPath expression depends on a $@.", 
       taintedSource.getNode(),
       "user-provided value"