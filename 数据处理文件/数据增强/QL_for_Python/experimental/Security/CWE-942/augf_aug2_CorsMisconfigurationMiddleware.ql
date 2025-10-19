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

from Http::Server::CorsMiddleware misconfiguredCorsMiddleware
where
  // Validate CORS middleware type and credentials configuration
  misconfiguredCorsMiddleware.getMiddlewareName() = "CORSMiddleware" and
  misconfiguredCorsMiddleware.getCredentialsAllowed().asExpr() instanceof True and
  // Check if origin configuration contains unsafe wildcard or null values
  exists(DataFlow::Node originNode |
    originNode = misconfiguredCorsMiddleware.getOrigins().getALocalSource() and
    (
      // Case 1: List containing wildcard/null string literals
      (originNode.asExpr() instanceof List and
       exists(StringLiteral strLiteral |
         strLiteral = originNode.asExpr().getASubExpression() and
         strLiteral.getText() in ["*", "null"]
       ))
      // Case 2: Direct wildcard/null string literal
      or
      (originNode.asExpr() instanceof StringLiteral and
       originNode.asExpr().(StringLiteral).getText() in ["*", "null"])
    )
  )
select misconfiguredCorsMiddleware,
  "This CORS middleware uses a vulnerable configuration that allows arbitrary websites to make authenticated cross-site requests"