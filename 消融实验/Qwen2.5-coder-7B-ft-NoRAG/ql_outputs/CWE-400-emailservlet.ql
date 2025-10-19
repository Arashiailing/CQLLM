/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @description The product does not properly control the allocation and maintenance of a limited resource.
 * @id py/emailservlet
 */

import python
import semmle.python.security.dataflow.HeaderInjectionQuery

from HeaderInjectionFlow::PathNode source, HeaderInjectionFlow::PathNode sink
where HeaderInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This HTTP header is constructed from a $@.", source.getNode(), "user-provided value"