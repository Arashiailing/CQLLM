/**
 * @name CORS misconfiguration with credentials enabled
 * @description Detects CORS middleware configurations that allow authenticated requests
 *              from arbitrary origins, potentially enabling cross-site attacks.
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

/** Determines if a node contains wildcard (*) or null origin values */
predicate containsUnsafeOrigin(DataFlow::Node originNode) {
  // Check for direct wildcard/null string literals
  exists(StringLiteral lit | lit = originNode.asExpr() and lit.getText() in ["*", "null"])
  or
  // Check lists containing wildcard/null elements
  exists(List lst | 
    lst = originNode.asExpr() and
    exists(StringLiteral elem | 
      elem = lst.getASubExpression() and
      elem.getText() in ["*", "null"]
    )
  )
}

/** Identifies CORS middleware configurations */
predicate isCorsMiddleware(Http::Server::CorsMiddleware middleware) {
  middleware.getMiddlewareName() = "CORSMiddleware"
}

/** Checks if credentials are explicitly enabled in CORS configuration */
predicate credentialsAreEnabled(Http::Server::CorsMiddleware middleware) {
  exists(True lit | lit = middleware.getCredentialsAllowed().asExpr())
}

from Http::Server::CorsMiddleware misconfiguredCorsMiddleware
where
  // Verify CORS middleware type
  isCorsMiddleware(misconfiguredCorsMiddleware) and
  // Check for enabled credentials
  credentialsAreEnabled(misconfiguredCorsMiddleware) and
  // Detect unsafe origin configurations
  containsUnsafeOrigin(misconfiguredCorsMiddleware.getOrigins().getALocalSource())
select misconfiguredCorsMiddleware,
  "This CORS middleware uses a vulnerable configuration that allows arbitrary websites to make authenticated cross-site requests"