/**
 * @name CORS misconfiguration with credentials enabled
 * @description Identifies CORS middleware configurations allowing authenticated requests
 *              from any origin, creating cross-site attack vectors
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

/** Checks if a node contains wildcard (*) or null origin values */
predicate containsUnsafeOrigin(DataFlow::Node originNode) {
  // Direct string literals with unsafe values
  exists(StringLiteral unsafeLiteral | 
    unsafeLiteral = originNode.asExpr() and 
    unsafeLiteral.getText() in ["*", "null"]
  )
  or
  // Lists containing unsafe origin elements
  exists(List originList | 
    originList = originNode.asExpr() and
    exists(StringLiteral listElement | 
      listElement = originList.getASubExpression() and
      listElement.getText() in ["*", "null"]
    )
  )
}

/** Validates CORS middleware identification */
predicate isCorsMiddleware(Http::Server::CorsMiddleware corsMiddleware) {
  corsMiddleware.getMiddlewareName() = "CORSMiddleware"
}

/** Verifies credentials are enabled in CORS configuration */
predicate credentialsAreEnabled(Http::Server::CorsMiddleware corsMiddleware) {
  exists(True trueLiteral | 
    trueLiteral = corsMiddleware.getCredentialsAllowed().asExpr()
  )
}

from Http::Server::CorsMiddleware misconfiguredCorsMiddleware
where
  // Confirm middleware is CORS type
  isCorsMiddleware(misconfiguredCorsMiddleware) and
  // Validate credentials are enabled
  credentialsAreEnabled(misconfiguredCorsMiddleware) and
  // Detect unsafe origin configuration
  containsUnsafeOrigin(misconfiguredCorsMiddleware.getOrigins().getALocalSource())
select misconfiguredCorsMiddleware,
  "This CORS middleware uses a vulnerable configuration that allows arbitrary websites to make authenticated cross-site requests"