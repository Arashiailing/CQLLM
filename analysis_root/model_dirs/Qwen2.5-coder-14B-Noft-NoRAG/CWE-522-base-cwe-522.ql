import python

/**
 * CWE-522: Insufficiently Protected Credentials
 * This query detects cases where credentials are stored in cleartext.
 */
from DataFlow::Node source, DataFlow::Node sink
where source instanceof Expr and sink instanceof Expr and
      DataFlow::localFlow(source, sink) and
      (source instanceof StringLiteral or source instanceof ConcatExpr) and
      (sink instanceof Variable or sink instanceof MemberAccess) and
      exists(Expr e | e = sink and e.getType() instanceof Type and
              e.getType().getName() = "str" and
              e.getType().getDeclaringType() instanceof Class and
              e.getType().getDeclaringType().getName() = "credentials")
select sink, "Credentials are stored in cleartext."