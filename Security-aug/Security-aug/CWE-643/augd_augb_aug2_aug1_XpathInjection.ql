/**
 * @name XPath injection via user-provided data
 * @description Identifies XPath query construction that incorporates
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

// Trace data flow paths from untrusted sources to vulnerable XPath sinks
from XpathInjectionFlow::PathNode maliciousInput, XpathInjectionFlow::PathNode xpathSink
where XpathInjectionFlow::flowPath(maliciousInput, xpathSink)
select 
  xpathSink.getNode(), 
  maliciousInput, 
  xpathSink, 
  "XPath expression incorporates a $@.", 
  maliciousInput.getNode(), 
  "user-controlled input"