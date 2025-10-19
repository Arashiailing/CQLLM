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

/** 检查节点是否包含通配符或null值 */
predicate containsWildcardOrNull(DataFlow::Node originNode) {
  // 检查列表类型节点是否包含"*"或"null"字符串字面量
  originNode.asExpr() instanceof List and
  originNode.asExpr().getASubExpression().(StringLiteral).getText() in ["*", "null"]
  // 检查节点本身是否为"*"或"null"字符串字面量
  or
  originNode.asExpr().(StringLiteral).getText() in ["*", "null"]
}

/** 验证中间件是否为CORS中间件 */
predicate isCorsConfiguredMiddleware(Http::Server::CorsMiddleware middleware) {
  middleware.getMiddlewareName() = "CORSMiddleware"
}

/** 检查CORS中间件是否启用了凭证支持 */
predicate hasCredentialsEnabled(Http::Server::CorsMiddleware middleware) {
  middleware.getCredentialsAllowed().asExpr() instanceof True
}

from Http::Server::CorsMiddleware vulnerableMiddleware
where
  // 验证中间件类型和凭证配置
  isCorsConfiguredMiddleware(vulnerableMiddleware) and
  hasCredentialsEnabled(vulnerableMiddleware) and
  // 检查来源配置是否包含不安全的通配符
  containsWildcardOrNull(vulnerableMiddleware.getOrigins().getALocalSource())
select vulnerableMiddleware,
  "This CORS middleware uses a vulnerable configuration that allows arbitrary websites to make authenticated cross-site requests"