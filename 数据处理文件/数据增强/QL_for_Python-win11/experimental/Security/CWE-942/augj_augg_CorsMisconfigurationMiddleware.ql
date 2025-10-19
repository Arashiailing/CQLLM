/**
 * @name Cors misconfiguration with credentials
 * @description Disabling or weakening SOP protection may make the application
 *              vulnerable to a CORS attack.
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

// Identifies CORS middleware components in the application
predicate isCorsMiddleware(Http::Server::CorsMiddleware corsConfig) {
  corsConfig.getMiddlewareName() = "CORSMiddleware"
}

// Checks if credentials are enabled in CORS configuration
predicate credentialsEnabled(Http::Server::CorsMiddleware corsConfig) {
  corsConfig.getCredentialsAllowed().asExpr() instanceof True
}

// Detects insecure origin configurations (wildcards or null values)
predicate hasInsecureOriginConfig(DataFlow::Node originConfigNode) {
  // Handles list-type origin configurations
  exists(List originList | 
    originList = originConfigNode.asExpr() and
    exists(StringLiteral originLiteral |
      originLiteral = originList.getASubExpression() and
      originLiteral.getText() in ["*", "null"]
    )
  )
  // Handles string-type origin configurations
  or
  exists(StringLiteral originLiteral |
    originLiteral = originConfigNode.asExpr() and
    originLiteral.getText() in ["*", "null"]
  )
}

// Main query detecting vulnerable CORS configurations
from Http::Server::CorsMiddleware vulnerableCorsConfig
where
  // Verify middleware type is CORS
  isCorsMiddleware(vulnerableCorsConfig) and
  // Verify credentials are enabled
  credentialsEnabled(vulnerableCorsConfig) and
  // Verify origin configuration contains wildcards
  hasInsecureOriginConfig(vulnerableCorsConfig.getOrigins().getALocalSource())
select vulnerableCorsConfig,
  "This CORS middleware uses a vulnerable configuration that allows arbitrary websites to make authenticated cross-site requests"