/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @id py/tls
 */
import python
import semmle.python.security.dataflow.DataFlow

from Call call
where call.getFunction().getName() = "sslwrap" and
      call.getArgument(0).getType().getName() = "str" and
      call.getArgument(1).getType().getName() = "int"
select call, "Potential uncontrolled resource consumption via sslwrap with unbounded parameters."