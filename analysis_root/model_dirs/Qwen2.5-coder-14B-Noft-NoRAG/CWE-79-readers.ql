import python

/**
 * This query detects potential CWE-79: Improper Neutralization of Special Elements used in an
 * HTTP Header (http header injection).
 */
from DataFlow::Node source, DataFlow::Node sink
where source.asExpr() instanceof Expr and
      sink.asExpr() instanceof Expr and
      DataFlow::localFlow(source, sink) and
      sink.asExpr().getAnEnclosingCallable() instanceof Function and
      sink.asExpr().getAnEnclosingCallable().getName() = "setHeader" and
      sink.asExpr().getArg(0).toString() = "Location"
select source, "This input may be vulnerable to HTTP header injection."