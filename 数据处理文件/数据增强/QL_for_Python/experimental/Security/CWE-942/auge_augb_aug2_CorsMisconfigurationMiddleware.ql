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

/** Identifies CORS middleware configurations */
predicate isCorsMiddleware(Http::Server::CorsMiddleware corsMiddleware) {
  corsMiddleware.getMiddlewareName() = "CORSMiddleware"
}

/** Checks if credentials are explicitly enabled in CORS configuration */
predicate credentialsAreEnabled(Http::Server::CorsMiddleware corsMiddleware) {
  exists(True lit | lit = corsMiddleware.getCredentialsAllowed().asExpr())
}

/** Determines if a node contains wildcard (*) or null origin values */
predicate containsUnsafeOrigin(DataFlow::Node originValueNode) {
  // Check for direct wildcard/null string literals
  exists(StringLiteral lit | lit = originValueNode.asExpr() and lit.getText() in ["*", "null"])
  or
  // Check lists containing wildcard/null elements
  exists(List lst | 
    lst = originValueNode.asExpr() and
    exists(StringLiteral elem | 
      elem = lst.getASubExpression() and
      elem.getText() in ["*", "null"]
    )
  )
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