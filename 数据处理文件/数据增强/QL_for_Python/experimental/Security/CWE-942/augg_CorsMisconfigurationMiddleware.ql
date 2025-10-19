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

// 检查中间件是否为CORS中间件
predicate isCorsMiddleware(Http::Server::CorsMiddleware corsMiddleware) {
  corsMiddleware.getMiddlewareName() = "CORSMiddleware"
}

// 检查CORS中间件是否启用了凭证支持
predicate credentialsAllowed(Http::Server::CorsMiddleware corsMiddleware) {
  corsMiddleware.getCredentialsAllowed().asExpr() instanceof True
}

// 检查来源配置是否包含通配符或null值
predicate containsWildcardOrigin(DataFlow::Node originNode) {
  // 处理列表形式的来源配置
  exists(List originList | 
    originList = originNode.asExpr() and
    exists(StringLiteral literal |
      literal = originList.getASubExpression() and
      literal.getText() in ["*", "null"]
    )
  )
  // 处理字符串形式的来源配置
  or
  exists(StringLiteral literal |
    literal = originNode.asExpr() and
    literal.getText() in ["*", "null"]
  )
}

// 查询存在安全风险的CORS配置
from Http::Server::CorsMiddleware corsMiddleware
where
  // 验证中间件类型
  isCorsMiddleware(corsMiddleware) and
  // 验证凭证启用状态
  credentialsAllowed(corsMiddleware) and
  // 验证来源配置安全性
  containsWildcardOrigin(corsMiddleware.getOrigins().getALocalSource())
select corsMiddleware,
  "This CORS middleware uses a vulnerable configuration that allows arbitrary websites to make authenticated cross-site requests"