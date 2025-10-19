/**
 * @name Cors misconfiguration with credentials
 * @description Disabling or weakening SOP protection may make the application
 *              vulnerable to a CORS attack.
 * @kind problem
 * @problem.severity warning
 * @security-severity 8.8
 * @precision high
 * @id py/cors-misconfiguration-with-credentials
 * @tags security
 *       experimental
 *       external/cwe/cwe-942
 */

import python
import semmle.python.Concepts
private import semmle.python.dataflow.new.DataFlow

/** Checks if a node contains wildcard or null values */
predicate containsWildcardOrNone(DataFlow::Node configNode) {
  // Check if list-type node contains "*" or "null" string literals
  exists(List lst | lst = configNode.asExpr() |
    exists(StringLiteral str | str = lst.getASubExpression() |
      str.getText() in ["*", "null"]
    )
  )
  // Check if node itself is "*" or "null" string literal
  or
  exists(StringLiteral str | str = configNode.asExpr() |
    str.getText() in ["*", "null"]
  )
}

from Http::Server::CorsMiddleware middleware
where
  // Verify middleware type and credential configuration
  middleware.getMiddlewareName() = "CORSMiddleware" and
  middleware.getCredentialsAllowed().asExpr() instanceof True and
  // Check if origin configuration contains unsafe wildcards
  exists(DataFlow::Node originNode | 
    originNode = middleware.getOrigins().getALocalSource() and
    containsWildcardOrNone(originNode)
  )
select middleware,
  "This CORS middleware uses a vulnerable configuration that allows arbitrary websites to make authenticated cross-site requests"