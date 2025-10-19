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
predicate containsUnsafeOrigin(DataFlow::Node originValueNode) {
  // Case 1: Direct wildcard/null string literals
  exists(StringLiteral literal | 
    literal = originValueNode.asExpr() and 
    literal.getText() in ["*", "null"]
  )
  or
  // Case 2: Lists containing wildcard/null elements
  exists(List originList | 
    originList = originValueNode.asExpr() and
    exists(StringLiteral listElement | 
      listElement = originList.getASubExpression() and
      listElement.getText() in ["*", "null"]
    )
  )
}

/** Identifies CORS middleware configurations */
predicate isCorsMiddleware(Http::Server::CorsMiddleware corsMiddleware) {
  corsMiddleware.getMiddlewareName() = "CORSMiddleware"
}

/** Checks if credentials are explicitly enabled in CORS configuration */
predicate credentialsAreEnabled(Http::Server::CorsMiddleware corsMiddleware) {
  exists(True literal | literal = corsMiddleware.getCredentialsAllowed().asExpr())
}

from Http::Server::CorsMiddleware vulnerableCorsConfig
where
  // Verify CORS middleware type
  isCorsMiddleware(vulnerableCorsConfig) and
  // Check for enabled credentials
  credentialsAreEnabled(vulnerableCorsConfig) and
  // Detect unsafe origin configurations
  containsUnsafeOrigin(vulnerableCorsConfig.getOrigins().getALocalSource())
select vulnerableCorsConfig,
  "This CORS middleware uses a vulnerable configuration that allows arbitrary websites to make authenticated cross-site requests"