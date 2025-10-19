import python

/**
 * A query to detect CWE-125: Out-of-bounds Read in Python code.
 */
from CallExpr call, Arg arg, DataFlow::Node src, DataFlow::Node sink
where call.getCallee().getName() = "open"
  and arg = call.getArgument(0)
  and DataFlow::localFlow(src, sink)
  and src.asExpr() instanceof StringLiteral
  and src.asExpr().getValue().matches(".*[\\x00-\\x1F].*")
select call, "This call to 'open' may be vulnerable to CWE-125: Out-of-bounds Read due to a potentially malicious file path."