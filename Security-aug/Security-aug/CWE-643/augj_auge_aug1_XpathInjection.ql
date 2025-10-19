/**
 * @name XPath injection vulnerability from user input
 * @description Detects security flaws where untrusted user input is directly incorporated
 *              into XPath queries, enabling attackers to inject malicious XPath syntax.
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

// Identify data flow paths from untrusted sources to vulnerable XPath query construction
from XpathInjectionFlow::PathNode untrustedSource, XpathInjectionFlow::PathNode vulnerableSink
where 
  // Establish complete data flow path from input source to XPath sink
  XpathInjectionFlow::flowPath(untrustedSource, vulnerableSink)
select 
  vulnerableSink.getNode(), 
  untrustedSource, 
  vulnerableSink, 
  "XPath expression incorporates $@.", 
  untrustedSource.getNode(), 
  "untrusted user input"