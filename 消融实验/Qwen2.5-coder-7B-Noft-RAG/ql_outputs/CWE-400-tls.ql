/**
* @name CWE-400: Uncontrolled Resource Consumption
*
@description The product does not properly control the allocation
    and maintenance of a limited resource.
* @kind path-problem
* @problem.severity error
* @precision high
* @security-severity 7.5
*
@id py/tls
*/
import python
import semmle.python.security.dataflow.TLSResourceConsumptionQuery
import TLSResourceConsumptionFlow::PathGraph
from TLSResourceConsumptionFlow::PathNode source, TLSResourceConsumptionFlow::PathNode sink
    where TLSResourceConsumptionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Resource consumption depends on a $@.", source.getNode(), "uncontrolled resource"