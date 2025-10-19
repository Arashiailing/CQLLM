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

/** Determines if a configuration node contains wildcard or null values */
predicate containsWildcardOrNone(DataFlow::Node cfgNode) {
  // Case 1: Node is a list containing "*" or "null" elements
  exists(List lstNode | lstNode = cfgNode.asExpr() |
    exists(StringLiteral strLiteral | strLiteral = lstNode.getASubExpression() |
      strLiteral.getText() in ["*", "null"]
    )
  )
  // Case 2: Node is directly a "*" or "null" string literal
  or
  exists(StringLiteral strLiteral | strLiteral = cfgNode.asExpr() |
    strLiteral.getText() in ["*", "null"]
  )
}

from Http::Server::CorsMiddleware middleware
where
  // Verify middleware type and credential configuration
  middleware.getMiddlewareName() = "CORSMiddleware" and
  middleware.getCredentialsAllowed().asExpr() instanceof True
  and
  // Check for unsafe wildcard in origin configuration
  exists(DataFlow::Node originCfgNode | 
    originCfgNode = middleware.getOrigins().getALocalSource() and
    containsWildcardOrNone(originCfgNode)
  )
select middleware,
  "This CORS middleware uses a vulnerable configuration that allows arbitrary websites to make authenticated cross-site requests"