/**
 * @name CORS Misconfiguration: Credentials with Wildcard Origins
 * @description Identifies CORS middleware setups that permit authenticated requests
 *              from any origin, creating a risk for cross-site request forgery attacks.
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

/** Recognizes CORS middleware configurations in the codebase */
predicate isCorsMiddleware(Http::Server::CorsMiddleware corsConfig) {
  corsConfig.getMiddlewareName() = "CORSMiddleware"
}

/** Verifies if credentials are explicitly activated in CORS settings */
predicate credentialsAreEnabled(Http::Server::CorsMiddleware corsConfig) {
  exists(True literal | literal = corsConfig.getCredentialsAllowed().asExpr())
}

/** Determines if a node represents wildcard (*) or null origin values */
predicate containsUnsafeOrigin(DataFlow::Node originNode) {
  // Check for direct wildcard/null string literals
  exists(StringLiteral literal | 
    literal = originNode.asExpr() and 
    literal.getText() in ["*", "null"]
  )
  or
  // Check lists containing wildcard/null elements
  exists(List originList | 
    originList = originNode.asExpr() and
    exists(StringLiteral listElement | 
      listElement = originList.getASubExpression() and
      listElement.getText() in ["*", "null"]
    )
  )
}

from Http::Server::CorsMiddleware insecureCorsSetup
where
  // Confirm CORS middleware type
  isCorsMiddleware(insecureCorsSetup) and
  // Validate credentials are enabled
  credentialsAreEnabled(insecureCorsSetup) and
  // Identify unsafe origin configurations
  containsUnsafeOrigin(insecureCorsSetup.getOrigins().getALocalSource())
select insecureCorsSetup,
  "This CORS middleware configuration is vulnerable as it allows authenticated requests from any origin"