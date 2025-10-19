import python

/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @description Detects instances where sensitive information is stored in cleartext.
 * @id py/sosreport
 */

class CleartextStorage extends DataFlow::Node {
  CleartextStorage() {
    exists(DataFlow::Node source, DataFlow::Node sink |
      this = sink and
      DataFlow::localFlow(source, this) and
      isSensitiveInformation(source)
    )
  }

  boolean isSensitiveInformation(DataFlow::Node node) {
    exists(Expr e |
      node.asExpr() = e and
      isSensitiveData(e)
    )
  }

  boolean isSensitiveData(Expr e) {
    e instanceof StringLiteral and
    e.getValue().matches("%(password|secret|key|token|credential)%i")
  }
}

from CleartextStorage node
select node, "Sensitive information is stored in cleartext."