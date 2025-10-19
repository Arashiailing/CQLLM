/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @id py/matrixfederationagent
 */
import python
import semmle.code.java.dataflow.DataFlow
import semmle.python.security.dataflow.ResourceConsumptionQuery

from ResourceAllocation alloc, ResourceExhaustion exhaust
where ResourceConsumptionFlow::flowPath(alloc, exhaust)
select alloc, "Potential uncontrolled resource consumption detected", exhaust