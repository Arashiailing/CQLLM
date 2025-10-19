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
predicate hasWildcardOrigin(DataFlow::Node originSetting) {
  exists(StringLiteral stringLiteral |
    // 情况1：来源配置是列表且包含 "*" 或 "null" 元素
    (originSetting.asExpr() instanceof List and
     stringLiteral = originSetting.asExpr().getASubExpression() and
     stringLiteral.getText() in ["*", "null"])
    or
    // 情况2：来源配置直接是 "*" 或 "null" 字符串
    (stringLiteral = originSetting.asExpr() and
     stringLiteral.getText() in ["*", "null"])
  )
}

// 验证中间件是否为 CORS 类型
predicate isCorsMiddlewareType(Http::Server::CorsMiddleware corsMiddleware) {
  corsMiddleware.getMiddlewareName() = "CORSMiddleware"
}

// 检查中间件是否启用了凭证支持
predicate supportsCredentials(Http::Server::CorsMiddleware corsMiddleware) {
  corsMiddleware.getCredentialsAllowed().asExpr() instanceof True
}

// 查询存在安全风险的 CORS 中间件配置
from Http::Server::CorsMiddleware middleware
where
  // 条件组合：启用凭证 + 使用通配符来源 + 确认中间件类型
  supportsCredentials(middleware) and
  hasWildcardOrigin(middleware.getOrigins().getALocalSource()) and
  isCorsMiddlewareType(middleware)
select middleware,
  // 安全风险说明：允许任意来源的认证请求可能导致敏感数据泄露
  "This CORS middleware configuration allows authenticated cross-origin requests from any source, potentially exposing sensitive data"