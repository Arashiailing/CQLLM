/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @description The product does not properly control the allocation and maintenance of a limited resource.
 * @kind problem
 * @problem.severity warning
 * @precision medium
 * @id py/well_known_resolver
 */

import python
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
import ServerSideRequestForgeryFlow::PathGraph
from ServerSideRequestForgeryFlow::PathNode source, ServerSideRequestForgeryFlow::PathNode sink
where ServerSideRequestForgeryFlow::flowPath(source, sink)
select sink.getNode(), "User-provided value flows into this resource manager."