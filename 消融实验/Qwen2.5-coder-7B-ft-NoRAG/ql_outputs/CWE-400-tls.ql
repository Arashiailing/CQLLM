/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @description The product does not properly control the allocation and maintenance of a limited resource.
 * @id py/tls
 */

import python
import semmle.python.security.dataflow.ResourceConsumptionQuery

from ResourceNode source, ResourceNode sink
where ResourceConsumptionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Resource consumption depends on a $@.", source.getNode(), "uncontrolled value"