import python

/**
 * @name CWE-522: Insufficiently Protected Credentials
 * @description This query detects instances where credentials are stored in cleartext.
 * @id py/settings
 */

from DataFlow::Node source, DataFlow::Node sink
where source.asExpr() instanceof MemberAccess and
      source.asExpr().getMemberName() = "password" and
      DataFlow::localFlow(source, sink) and
      sink.asExpr() instanceof StringLiteral
select sink, "Credentials are stored in cleartext."