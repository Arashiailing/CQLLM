/**
 * @name XPath injection via user-provided data
 * @description Detects XPath query construction patterns that incorporate 
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

// Identify data flow routes from untrusted sources to vulnerable XPath sinks
from 
  XpathInjectionFlow::PathNode maliciousSource,
  XpathInjectionFlow::PathNode vulnerableSink
where 
  XpathInjectionFlow::flowPath(maliciousSource, vulnerableSink)
select 
  vulnerableSink.getNode(), 
  maliciousSource, 
  vulnerableSink, 
  "XPath expression incorporates a $@.", 
  maliciousSource.getNode(), 
  "user-controlled input"