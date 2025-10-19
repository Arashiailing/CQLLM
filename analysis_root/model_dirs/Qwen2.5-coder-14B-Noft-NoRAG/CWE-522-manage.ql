import python

/**
 * @name CWE-522: Insufficiently Protected Credentials
 * @description Detects cases where credentials are stored in cleartext.
 * @id py/manage
 */

from DataFlow::Node source, DataFlow::Node sink
where source.asExpr() instanceof Identifier and
      source.asExpr().getName() = "password" and
      sink.asExpr() instanceof StringLiteral and
      DataFlow::localFlow(source, sink)
select sink, "Credentials are stored in cleartext."