/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @description The product does not properly control the allocation and maintenance of a limited resource.
 * @kind problem
 * @problem.severity warning
 * @precision high
 * @security-severity 7.5
 * @id py/tls
 * @tags security
 *       external/cwe/cwe-400
 */

import python
import semmle.python.security.dataflow.TLSInjectionQuery
import TLSInjectionFlow::PathGraph

from TLSInjectionFlow::PathNode source, TLSInjectionFlow::PathNode sink
where TLSInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "TLS connection parameter depends on a $@.", source.getNode(), "user-provided value"