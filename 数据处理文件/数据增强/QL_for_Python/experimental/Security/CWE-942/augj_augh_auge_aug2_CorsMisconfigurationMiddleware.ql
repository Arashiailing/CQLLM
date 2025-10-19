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

/** 
 * Checks if a configuration node contains unsafe wildcard or null values.
 * Two cases are covered:
 * 1. List containing "*" or "null" elements
 * 2. Direct "*" or "null" string literal
 */
predicate hasUnsafeOriginConfig(DataFlow::Node configNode) {
  // Case 1: Check for unsafe values in list elements
  exists(List listNode | listNode = configNode.asExpr() |
    exists(StringLiteral strLit | strLit = listNode.getASubExpression() |
      strLit.getText() in ["*", "null"]
    )
  )
  // Case 2: Check for direct unsafe string literals
  or
  exists(StringLiteral strLit | strLit = configNode.asExpr() |
    strLit.getText() in ["*", "null"]
  )
}

from Http::Server::CorsMiddleware corsMiddleware
where
  // Verify middleware type and credential configuration
  corsMiddleware.getMiddlewareName() = "CORSMiddleware" and
  corsMiddleware.getCredentialsAllowed().asExpr() instanceof True
  and
  // Check for unsafe origin configuration
  exists(DataFlow::Node originConfigNode | 
    originConfigNode = corsMiddleware.getOrigins().getALocalSource() and
    hasUnsafeOriginConfig(originConfigNode)
  )
select corsMiddleware,
  "This CORS middleware uses a vulnerable configuration that allows arbitrary websites to make authenticated cross-site requests"