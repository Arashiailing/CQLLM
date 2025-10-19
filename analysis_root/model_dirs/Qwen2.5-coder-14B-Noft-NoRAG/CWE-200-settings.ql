import python

/**
 * CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * This query detects instances where sensitive information is stored in cleartext.
 */

from DataFlow::Node src, DataFlow::Node sink
where src instanceof Expr and sink instanceof Expr and
      DataFlow::localFlow(src, sink) and
      isSensitiveInfo(src) and
      isCleartextStorage(sink)
select src, "Sensitive information is stored in cleartext."

import python

/**
 * Helper predicate to determine if an expression is considered sensitive information.
 */
predicate isSensitiveInfo(Expr e) {
  e instanceof Str and
  e.getValue() matches "%(password|secret|token|key)%i"
}

/**
 * Helper predicate to determine if an expression is a cleartext storage location.
 */
predicate isCleartextStorage(Expr e) {
  e instanceof Call and
  e.getCallee().getName() matches "open|write|save|put|store"
}