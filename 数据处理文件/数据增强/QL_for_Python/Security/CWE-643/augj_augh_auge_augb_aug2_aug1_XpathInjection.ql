/**
 * @name XPath injection via user-provided data
 * @description Identifies XPath query construction patterns that incorporate 
 *              unvalidated user input, potentially enabling malicious 
 *              XPath expression injection attacks.
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

// Trace data flow routes from untrusted sources to vulnerable XPath sinks
from 
  XpathInjectionFlow::PathNode untrustedSource,
  XpathInjectionFlow::PathNode xpathSink
where 
  XpathInjectionFlow::flowPath(untrustedSource, xpathSink)
select 
  xpathSink.getNode(), 
  untrustedSource, 
  xpathSink, 
  "XPath expression incorporates a $@.", 
  untrustedSource.getNode(), 
  "user-controlled input"