/**
 * @name XPath injection via user-provided data
 * @description Detects construction of XPath queries that incorporate
 *              unvalidated user input, potentially allowing malicious
 *              XPath expression injection.
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

// Identify potential data flow paths from untrusted sources to XPath query construction
from XpathInjectionFlow::PathNode taintedSource, XpathInjectionFlow::PathNode vulnerableSink
where XpathInjectionFlow::flowPath(taintedSource, vulnerableSink)
select 
  vulnerableSink.getNode(), 
  taintedSource, 
  vulnerableSink, 
  "XPath expression incorporates a $@.", 
  taintedSource.getNode(), 
  "user-controlled input"