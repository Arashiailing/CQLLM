/**
 * @name CORS misconfiguration with credentials enabled
 * @description Identifies CORS middleware configurations permitting authenticated requests
 *              from untrusted origins, potentially enabling cross-site request forgery attacks
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

/** Determines if a configuration node contains wildcard (*) or null origin values */
predicate containsUnsafeOrigin(DataFlow::Node originValueNode) {
  // Check for direct wildcard/null string literals
  exists(StringLiteral lit | 
    lit = originValueNode.asExpr() and 
    lit.getText() in ["*", "null"]
  )
  or
  // Check lists containing wildcard/null elements
  exists(List originList | 
    originList = originValueNode.asExpr() and
    exists(StringLiteral listElement | 
      listElement = originList.getASubExpression() and
      listElement.getText() in ["*", "null"]
    )
  )
}

/** Identifies CORS middleware instances in the application */
predicate isCorsMiddleware(Http::Server::CorsMiddleware corsMiddleware) {
  corsMiddleware.getMiddlewareName() = "CORSMiddleware"
}

/** Verifies if credentials are explicitly enabled in CORS configuration */
predicate credentialsAreEnabled(Http::Server::CorsMiddleware corsMiddleware) {
  exists(True credentialFlag | 
    credentialFlag = corsMiddleware.getCredentialsAllowed().asExpr()
  )
}

from Http::Server::CorsMiddleware vulnerableCorsMiddleware
where
  // Confirm the middleware is a CORS configuration
  isCorsMiddleware(vulnerableCorsMiddleware) and
  // Verify credentials are enabled for authenticated requests
  credentialsAreEnabled(vulnerableCorsMiddleware) and
  // Detect unsafe origin configurations (wildcard/null)
  containsUnsafeOrigin(vulnerableCorsMiddleware.getOrigins().getALocalSource())
select vulnerableCorsMiddleware,
  "This CORS middleware uses a vulnerable configuration that allows arbitrary websites to make authenticated cross-site requests"