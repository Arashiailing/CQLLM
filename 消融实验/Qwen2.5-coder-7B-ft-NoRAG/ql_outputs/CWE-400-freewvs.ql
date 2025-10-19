/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @description The product does not properly control the allocation and maintenance of a limited resource.
 * @id py/freewvs
 */
import python
import semmle.python.security.dataflow.ResourceConsumptionQuery
import ResourceConsumptionFlow::PathGraph

from ResourceConsumptionFlow::PathNode source, ResourceConsumptionFlow::PathNode sink
where ResourceConsumptionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Resource consumption depends on a $@.", source.getNode(), "uncontrolled value"