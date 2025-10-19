/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @description The product does not properly control the allocation and maintenance of a limited resource.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 7.5
 * @id py/client-cwe-400
 * @tags security
 *       external/cwe/cwe-400
 */

import python
import semmle.python.security.dataflow.XpathInjectionQuery
import XpathInjectionFlow::PathGraph
from XpathInjectionFlow::PathNode source, XpathInjectionFlow::PathNode sink
where XpathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "XPath expression depends on a $@.", source.getNode(),  "user-provided value"