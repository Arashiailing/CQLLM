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

// Detect data flow paths from untrusted sources to XPath query construction
from 
  XpathInjectionFlow::PathNode contaminatedSource, 
  XpathInjectionFlow::PathNode unsafeSink
where 
  XpathInjectionFlow::flowPath(contaminatedSource, unsafeSink)
select 
  unsafeSink.getNode(), 
  contaminatedSource, 
  unsafeSink, 
  "XPath expression incorporates a $@.", 
  contaminatedSource.getNode(), 
  "user-controlled input"