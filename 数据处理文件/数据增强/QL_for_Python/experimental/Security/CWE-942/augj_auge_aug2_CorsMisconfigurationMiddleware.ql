/**
 * @name CORS Misconfiguration with Credentials
 * @description Detects insecure CORS configurations where credentials are allowed
 *              alongside wildcard origins, bypassing Same-Origin Policy protections.
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

/** Determines if a configuration node contains wildcard or null origin values */
predicate hasWildcardOrNoneOrigin(DataFlow::Node configNode) {
  // Case 1: List-type node containing "*" or "null" literals
  exists(List originList | originList = configNode.asExpr() |
    exists(StringLiteral originValue | originValue = originList.getASubExpression() |
      originValue.getText() in ["*", "null"]
    )
  )
  // Case 2: Direct wildcard/null string literal
  or
  exists(StringLiteral originValue | originValue = configNode.asExpr() |
    originValue.getText() in ["*", "null"]
  )
}

from Http::Server::CorsMiddleware corsMiddleware
where
  // Identify CORS middleware with credentials enabled
  corsMiddleware.getMiddlewareName() = "CORSMiddleware" and
  corsMiddleware.getCredentialsAllowed().asExpr() instanceof True and
  // Detect insecure origin configurations
  exists(DataFlow::Node originConfigNode | 
    originConfigNode = corsMiddleware.getOrigins().getALocalSource() and
    hasWildcardOrNoneOrigin(originConfigNode)
  )
select corsMiddleware,
  "This CORS middleware allows credentials with wildcard origins, enabling authenticated cross-site attacks"