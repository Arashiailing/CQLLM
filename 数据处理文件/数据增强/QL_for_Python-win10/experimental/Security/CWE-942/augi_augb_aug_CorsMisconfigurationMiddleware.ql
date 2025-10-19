/**
 * @name CORS Misconfiguration with Credentials
 * @description Same-Origin Policy (SOP) protection is weakened when CORS is configured
 *              to allow credentials with wildcard or null origins, creating security risks.
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

// Check if CORS origin configuration contains wildcard or null values
predicate hasPermissiveOrigin(DataFlow::Node corsOriginNode) {
  // Case 1: Origin config is a list containing "*" or "null" elements
  corsOriginNode.asExpr() instanceof List and
  exists(StringLiteral originStr |
    originStr = corsOriginNode.asExpr().getASubExpression() and
    originStr.getText() in ["*", "null"]
  )
  // Case 2: Origin config directly uses "*" or "null" string
  or
  exists(StringLiteral originStr |
    originStr = corsOriginNode.asExpr() and
    originStr.getText() in ["*", "null"]
  )
}

// Identify CORS middleware configurations that present security vulnerabilities
from Http::Server::CorsMiddleware corsConfig
where
  // Verify middleware is of CORS type
  corsConfig.getMiddlewareName() = "CORSMiddleware" and
  // Check if middleware enables credential support
  corsConfig.getCredentialsAllowed().asExpr() instanceof True and
  // Check if origin configuration contains wildcard or null values
  hasPermissiveOrigin(corsConfig.getOrigins().getALocalSource())
select corsConfig,
  // Security impact description: Potential data exposure through authenticated cross-origin requests
  "This CORS middleware configuration allows authenticated cross-origin requests from any source, potentially exposing sensitive data"