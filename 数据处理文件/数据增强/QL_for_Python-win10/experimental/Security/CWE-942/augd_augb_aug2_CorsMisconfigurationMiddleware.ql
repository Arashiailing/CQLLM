/**
 * @name CORS misconfiguration with credentials enabled
 * @description Identifies CORS middleware configurations that permit authenticated requests
 *              from any origin, which could lead to cross-site request forgery attacks.
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
 * Checks if a node represents an unsafe origin configuration.
 * An origin is considered unsafe if it contains wildcard (*) or null values,
 * which allows requests from any source.
 */
predicate hasUnsafeOriginSetting(DataFlow::Node originValueNode) {
  // Direct string literals with wildcard or null
  exists(StringLiteral literal | 
    literal = originValueNode.asExpr() and 
    literal.getText() in ["*", "null"]
  )
  or
  // Lists containing wildcard or null elements
  exists(List listExpr | 
    listExpr = originValueNode.asExpr() and
    exists(StringLiteral listElement | 
      listElement = listExpr.getASubExpression() and
      listElement.getText() in ["*", "null"]
    )
  )
}

/**
 * Determines if the given middleware is a CORS middleware.
 * This is identified by checking the middleware name.
 */
predicate isCorsConfig(Http::Server::CorsMiddleware corsMiddleware) {
  corsMiddleware.getMiddlewareName() = "CORSMiddleware"
}

/**
 * Verifies if credentials are explicitly enabled in the CORS configuration.
 * This is a security-sensitive setting that should not be combined with wildcard origins.
 */
predicate hasCredentialsEnabled(Http::Server::CorsMiddleware corsMiddleware) {
  exists(True literal | literal = corsMiddleware.getCredentialsAllowed().asExpr())
}

from Http::Server::CorsMiddleware vulnerableCorsConfig
where
  // Confirm it's a CORS middleware
  isCorsConfig(vulnerableCorsConfig) and
  // Check if credentials are enabled
  hasCredentialsEnabled(vulnerableCorsConfig) and
  // Verify the origin configuration is unsafe
  hasUnsafeOriginSetting(vulnerableCorsConfig.getOrigins().getALocalSource())
select vulnerableCorsConfig,
  "This CORS middleware uses a vulnerable configuration that allows arbitrary websites to make authenticated cross-site requests"