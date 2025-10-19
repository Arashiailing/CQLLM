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

/**
 * 检查 CORS 来源配置是否包含通配符或空值。
 * 这种配置允许来自任何来源的请求，可能导致安全风险。
 * 
 * @param corsOriginConfig - 表示 CORS 来源配置的数据流节点
 */
predicate hasWildcardOrigin(DataFlow::Node corsOriginConfig) {
  // 情况1：来源配置是列表且包含 "*" 或 "null" 元素
  corsOriginConfig.asExpr() instanceof List and
  exists(StringLiteral originLiteral |
    originLiteral = corsOriginConfig.asExpr().getASubExpression() and
    originLiteral.getText() in ["*", "null"]
  )
  // 情况2：来源配置直接是 "*" 或 "null" 字符串
  or
  exists(StringLiteral originLiteral |
    originLiteral = corsOriginConfig.asExpr() and
    originLiteral.getText() in ["*", "null"]
  )
}

/**
 * 验证中间件是否为 CORS 类型并启用了凭证支持。
 * 这种组合配置特别危险，因为它允许跨域请求携带认证信息。
 * 
 * @param corsMiddleware - 要检查的 CORS 中间件
 */
predicate isCorsWithCredentials(Http::Server::CorsMiddleware corsMiddleware) {
  corsMiddleware.getMiddlewareName() = "CORSMiddleware" and
  corsMiddleware.getCredentialsAllowed().asExpr() instanceof True
}

/**
 * 查询存在安全风险的 CORS 中间件配置。
 * 这种配置同时允许凭证和使用通配符来源，可能导致敏感数据泄露。
 */
from Http::Server::CorsMiddleware corsMiddleware
where
  // 首先确认是 CORS 中间件并启用了凭证支持
  isCorsWithCredentials(corsMiddleware) and
  // 然后检查来源配置是否包含通配符或空值
  hasWildcardOrigin(corsMiddleware.getOrigins().getALocalSource())
select corsMiddleware,
  // 安全风险说明：允许任意来源的认证请求可能导致敏感数据泄露
  "This CORS middleware configuration allows authenticated cross-origin requests from any source, potentially exposing sensitive data"