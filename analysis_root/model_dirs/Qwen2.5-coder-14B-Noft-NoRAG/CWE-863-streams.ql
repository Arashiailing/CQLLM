import python

/**
 * This query detects CWE-863: Incorrect Authorization in Python code.
 * It looks for cases where an authorization check is performed,
 * but the check is not correctly implemented.
 */

class IncorrectAuthorization extends DataFlow::Node {
  IncorrectAuthorization() {
    exists(DataFlow::Node source, DataFlow::Node sink |
      this = sink and
      source.asExpr() instanceof Call and
      source.asExpr().getCallee().getName() = "check_authorization" and
      not (sink.asExpr() instanceof IfStmt and
           sink.asExpr().getCondition() = source.asExpr())
    )
  }
}

from IncorrectAuthorization node
select node, "This authorization check is not correctly implemented."