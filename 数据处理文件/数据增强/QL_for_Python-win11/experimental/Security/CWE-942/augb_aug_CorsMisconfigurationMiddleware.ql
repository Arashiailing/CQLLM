/**
 * @name CORS Misconfiguration with Credentials
 * @description Disabling or weakening Same-Origin Policy (SOP) protection may expose
 *              the application to CORS attacks when credentials are allowed.
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

// Check if origin configuration contains wildcard or null values
predicate containsWildcardOrNull(DataFlow::Node originConfigNode) {
  // Case 1: Origin config is a list containing "*" or "null" elements
  originConfigNode.asExpr() instanceof List and
  exists(StringLiteral strLiteral |
    strLiteral = originConfigNode.asExpr().getASubExpression() and
    strLiteral.getText() in ["*", "null"]
  )
  // Case 2: Origin config directly uses "*" or "null" string
  or
  exists(StringLiteral strLiteral |
    strLiteral = originConfigNode.asExpr() and
    strLiteral.getText() in ["*", "null"]
  )
}

// Verify middleware is of CORS type
predicate isCorsTypeMiddleware(Http::Server::CorsMiddleware corsMiddleware) {
  corsMiddleware.getMiddlewareName() = "CORSMiddleware"
}

// Check if middleware enables credential support
predicate hasCredentialsEnabled(Http::Server::CorsMiddleware corsMiddleware) {
  corsMiddleware.getCredentialsAllowed().asExpr() instanceof True
}

// Identify CORS middleware configurations with security risks
from Http::Server::CorsMiddleware corsMiddleware
where
  // Combined conditions: CORS type + credentials enabled + wildcard origins
  isCorsTypeMiddleware(corsMiddleware) and
  hasCredentialsEnabled(corsMiddleware) and
  containsWildcardOrNull(corsMiddleware.getOrigins().getALocalSource())
select corsMiddleware,
  // Security risk description: Authenticated cross-origin requests from any source may lead to data exposure
  "This CORS middleware configuration allows authenticated cross-origin requests from any source, potentially exposing sensitive data"