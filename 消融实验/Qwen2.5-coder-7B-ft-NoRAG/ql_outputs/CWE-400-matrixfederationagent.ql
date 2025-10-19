/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @description The product does not properly control the allocation and maintenance of a limited resource.
 * @id py/matrixfederationagent
 */

import python
import semmle.python.security.dataflow.UncontrolledResourceConsumptionQuery

from Function func, Call call
where func.getQualifiedName() = "matrix.federation_agent" and call.getCallee() = func
select call, "This function call consumes a limited resource uncontrollably."