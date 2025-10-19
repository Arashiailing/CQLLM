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

// Validate CORS middleware type
predicate isCorsType(Http::Server::CorsMiddleware middlewareInstance) {
  middlewareInstance.getMiddlewareName() = "CORSMiddleware"
}

// Check if credentials are enabled
predicate allowsCredentials(Http::Server::CorsMiddleware middlewareInstance) {
  middlewareInstance.getCredentialsAllowed().asExpr() instanceof True
}

// Detect wildcard or null origin configurations
predicate containsWildcardOrigin(DataFlow::Node originConfigNode) {
  // Case 1: Origin is a list containing "*" or "null"
  originConfigNode.asExpr() instanceof List and
  exists(StringLiteral wildcardLiteral |
    wildcardLiteral = originConfigNode.asExpr().getASubExpression() and
    wildcardLiteral.getText() in ["*", "null"]
  )
  // Case 2: Origin is directly "*" or "null" string
  or
  exists(StringLiteral wildcardLiteral |
    wildcardLiteral = originConfigNode.asExpr() and
    wildcardLiteral.getText() in ["*", "null"]
  )
}

// Identify risky CORS configurations
from Http::Server::CorsMiddleware middlewareInstance
where
  // Combined conditions: valid CORS type + credentials enabled + wildcard origin
  isCorsType(middlewareInstance) and
  allowsCredentials(middlewareInstance) and
  containsWildcardOrigin(middlewareInstance.getOrigins().getALocalSource())
select middlewareInstance,
  "This CORS middleware configuration allows authenticated cross-origin requests from any source, potentially exposing sensitive data"