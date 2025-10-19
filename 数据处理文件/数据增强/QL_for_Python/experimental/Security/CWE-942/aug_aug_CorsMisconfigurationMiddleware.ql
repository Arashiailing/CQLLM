/**
 * @name CORS Misconfiguration Involving Credential Support
 * @description Applications that weaken or bypass Same-Origin Policy (SOP) safeguards
 *              may become vulnerable to CORS-based attacks when credentials are permitted.
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

// 判断来源配置是否包含通配符或空值
predicate hasWildcardOrigin(DataFlow::Node sourceConfig) {
  // 场景1：来源配置是列表且包含 "*" 或 "null" 元素
  sourceConfig.asExpr() instanceof List and
  exists(StringLiteral stringLiteral |
    stringLiteral = sourceConfig.asExpr().getASubExpression() and
    stringLiteral.getText() in ["*", "null"]
  )
  // 场景2：来源配置直接是 "*" 或 "null" 字符串
  or
  exists(StringLiteral stringLiteral |
    stringLiteral = sourceConfig.asExpr() and
    stringLiteral.getText() in ["*", "null"]
  )
}

// 确认中间件是否为 CORS 类型
predicate isCorsMiddlewareType(Http::Server::CorsMiddleware corsMiddleware) {
  corsMiddleware.getMiddlewareName() = "CORSMiddleware"
}

// 检测中间件是否启用了凭证支持
predicate supportsCredentials(Http::Server::CorsMiddleware corsMiddleware) {
  corsMiddleware.getCredentialsAllowed().asExpr() instanceof True
}

// 查找存在安全风险的 CORS 中间件配置
from Http::Server::CorsMiddleware corsMiddleware
where
  // 组合条件：启用凭证 + 使用通配符来源 + 确认中间件类型
  supportsCredentials(corsMiddleware) and
  hasWildcardOrigin(corsMiddleware.getOrigins().getALocalSource()) and
  isCorsMiddlewareType(corsMiddleware)
select corsMiddleware,
  // 安全风险描述：允许任意来源的认证请求可能导致敏感数据泄露
  "This CORS middleware configuration allows authenticated cross-origin requests from any source, potentially exposing sensitive data"