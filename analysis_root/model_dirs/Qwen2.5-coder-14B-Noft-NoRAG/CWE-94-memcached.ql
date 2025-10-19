import python

/**
 * This query detects instances of CWE-94: Unsafe Deserialization in Python code.
 * It looks for calls to `pickle.loads` or `json.loads` with user-controlled input.
 */

from FunctionCall call, DataFlow::Node source, DataFlow::Node sink
where call.getCallee().getName() = "loads" and
      call.getCallee().getDeclaringType().getName() in ["pickle", "json"] and
      DataFlow::localFlow(source, sink) and
      source instanceof CallArgument and
      source.getAncestor(0) = call and
      source.getIndex() = 0 and
      source.asExpr() instanceof VariableAccess and
      source.asExpr().getVariable().getDeclaringScope().isUserInput()
select call, "This call to " + call.getCallee().getName() + " with user-controlled input may be vulnerable to CWE-94: Unsafe Deserialization."