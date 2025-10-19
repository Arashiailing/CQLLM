import semmle.python.dataflow.DataFlow
import semmle.python.Python

from CallExpr call, StringLiteral str
where call.getDirectlyCalledMethod().getName() in ("info", "debug", "warning", "error", "critical") and call.getArgument(0) = str
select call, "Potential sensitive information logged in log."