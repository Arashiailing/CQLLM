/** @name CWE-400: Uncontrolled Resource Consumption */
import python
import semmle.python.security.dataflow.ResourceConsumptionQuery

from ResourceConsumptionFlow::PathNode source, ResourceConsumptionFlow::PathNode sink
where ResourceConsumptionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Resource consumption vulnerability detected from $@.", source.getNode(), "uncontrolled data"