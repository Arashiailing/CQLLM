/**
 * @name CORS misconfiguration with credentials enabled
 * @description Identifies CORS middleware configurations permitting authenticated requests
 *              from any origin, potentially enabling cross-site attacks.
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

/** Checks if CORS middleware is configured with wildcard/null origins */
predicate containsUnsafeOrigin(DataFlow::Node originValueNode) {
  // Direct wildcard/null string literals
  exists(StringLiteral lit | 
    lit = originValueNode.asExpr() and 
    lit.getText() in ["*", "null"]
  )
  or
  // Lists containing wildcard/null elements
  exists(List lst | 
    lst = originValueNode.asExpr() and
    exists(StringLiteral elem | 
      elem = lst.getASubExpression() and
      elem.getText() in ["*", "null"]
    )
  )
}

/** Validates CORS middleware type */
predicate isCorsMiddleware(Http::Server::CorsMiddleware middlewareConfig) {
  middlewareConfig.getMiddlewareName() = "CORSMiddleware"
}

/** Verifies credentials are explicitly enabled */
predicate credentialsAreEnabled(Http::Server::CorsMiddleware middlewareConfig) {
  exists(True lit | lit = middlewareConfig.getCredentialsAllowed().asExpr())
}

from Http::Server::CorsMiddleware misconfiguredMiddleware
where
  // Confirm middleware type
  isCorsMiddleware(misconfiguredMiddleware) and
  // Check credential configuration
  credentialsAreEnabled(misconfiguredMiddleware) and
  // Detect unsafe origin settings
  containsUnsafeOrigin(misconfiguredMiddleware.getOrigins().getALocalSource())
select misconfiguredMiddleware,
  "This CORS middleware uses a vulnerable configuration that allows arbitrary websites to make authenticated cross-site requests"