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

// Identify data flow sources (user-controlled inputs) and sinks (XPath evaluation points)
from 
  XpathInjectionFlow::PathNode maliciousSource,  // Represents untrusted user input
  XpathInjectionFlow::PathNode xPathSink         // Represents vulnerable XPath execution

// Trace complete data flow paths from malicious sources to XPath sinks
where 
  XpathInjectionFlow::flowPath(maliciousSource, xPathSink)

// Report vulnerability details with source/sink locations and flow path
select 
  xPathSink.getNode(),                    // Sink location where XPath is executed
  maliciousSource,                        // Source node for path visualization
  xPathSink,                              // Sink node for path visualization
  "XPath expression depends on a $@.",    // Alert message template
  maliciousSource.getNode(),              // Source location for message parameter
  "user-provided value"                   // Source description in alert