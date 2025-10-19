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

// 检查来源配置是否包含通配符或空值
predicate hasWildcardOrigin(DataFlow::Node originConfigNode) {
  // 情况1：来源配置直接是 "*" 或 "null" 字符串
  exists(StringLiteral literal |
    literal = originConfigNode.asExpr() and
    literal.getText() in ["*", "null"]
  )
  // 情况2：来源配置是列表且包含 "*" 或 "null" 元素
  or
  originConfigNode.asExpr() instanceof List and
  exists(StringLiteral literal |
    literal = originConfigNode.asExpr().getASubExpression() and
    literal.getText() in ["*", "null"]
  )
}

// 验证中间件是否为 CORS 类型
predicate isCorsMiddlewareType(Http::Server::CorsMiddleware corsConfig) {
  corsConfig.getMiddlewareName() = "CORSMiddleware"
}

// 检查中间件是否启用了凭证支持
predicate supportsCredentials(Http::Server::CorsMiddleware corsConfig) {
  corsConfig.getCredentialsAllowed().asExpr() instanceof True
}

// 查询存在安全风险的 CORS 中间件配置
from Http::Server::CorsMiddleware corsConfig
where
  // 条件组合：确认中间件类型 + 启用凭证 + 使用通配符来源
  isCorsMiddlewareType(corsConfig) and
  supportsCredentials(corsConfig) and
  hasWildcardOrigin(corsConfig.getOrigins().getALocalSource())
select corsConfig,
  // 安全风险说明：允许任意来源的认证请求可能导致敏感数据泄露
  "This CORS middleware configuration allows authenticated cross-origin requests from any source, potentially exposing sensitive data"