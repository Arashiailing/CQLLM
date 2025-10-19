/**
* @name CWE-400: Uncontrolled Resource Consumption
*
@description The product does not properly control the allocation
    and maintenance of a limited resource.
* @kind path-problem
* @problem.severity warning
* @precision high
* @security-severity 7.5
*
@id py/store_invite_servlet
*/
import python
import semmle.python.security.dataflow.UncontrolledResourceConsumptionQuery
from PathNode source, PathNode sink
    where UncontrolledResourceConsumptionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Uncontrolled resource consumption detected at $@.", source.getNode(), "uncontrolled resource"