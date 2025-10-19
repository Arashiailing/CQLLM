/**
 * @name XPath query built from user-controlled sources
 * @description Detects construction of XPath queries using user-controlled input,
 *              which allows injection of malicious XPath expressions.
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

// Identify vulnerable XPath injection paths
from XpathInjectionFlow::PathNode taintedSource, XpathInjectionFlow::PathNode vulnerableSink
where XpathInjectionFlow::flowPath(taintedSource, vulnerableSink)
select vulnerableSink.getNode(), 
       taintedSource, 
       vulnerableSink, 
       "XPath expression depends on a $@.", 
       taintedSource.getNode(), 
       "user-provided value"