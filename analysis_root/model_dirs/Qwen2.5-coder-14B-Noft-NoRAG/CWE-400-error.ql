import python

/**
 * This query detects CWE-400: Uncontrolled Resource Consumption.
 * It looks for instances where resources are not properly controlled.
 */

from Call call, DataFlow::Node source, DataFlow::Node sink
where call.getCallee().getName() = "os.system" and
      DataFlow::localFlow(source, sink) and
      source instanceof Expr
select source, "This call to os.system may lead to uncontrolled resource consumption."