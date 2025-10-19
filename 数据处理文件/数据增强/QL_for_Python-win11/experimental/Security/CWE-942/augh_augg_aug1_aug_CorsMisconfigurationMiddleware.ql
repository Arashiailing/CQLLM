/**
 * @name CORS Misconfiguration with Credentials
 * @description Detects when CORS (Cross-Origin Resource Sharing) is configured to allow
 *              credentials while also permitting requests from any origin ('*') or null origins,
 *              which can lead to sensitive data exposure through cross-origin attacks.
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

// 检查CORS源配置是否包含不安全的通配符或空值
predicate containsInsecureOrigin(DataFlow::Node corsOriginConfig) {
  // 检查直接字符串值是否为不安全的通配符或空值
  exists(StringLiteral originLiteral |
    originLiteral = corsOriginConfig.asExpr() and
    originLiteral.getText() in ["*", "null"]
  )
  or
  // 检查列表配置中是否包含不安全的通配符或空值元素
  exists(List originListLiteral | originListLiteral = corsOriginConfig.asExpr() |
    exists(StringLiteral originLiteral |
      originLiteral = originListLiteral.getASubExpression() and
      originLiteral.getText() in ["*", "null"]
    )
  )
}

// 验证中间件是否为CORS类型中间件
predicate isCorsTypeMiddleware(Http::Server::CorsMiddleware corsMiddlewareInstance) {
  corsMiddlewareInstance.getMiddlewareName() = "CORSMiddleware"
}

// 检查中间件是否配置为支持凭证
predicate allowsCredentials(Http::Server::CorsMiddleware corsMiddlewareInstance) {
  corsMiddlewareInstance.getCredentialsAllowed().asExpr() instanceof True
}

// 检查是否存在安全风险的CORS中间件配置组合
predicate hasVulnerableCorsConfiguration(Http::Server::CorsMiddleware corsMiddlewareInstance) {
  isCorsTypeMiddleware(corsMiddlewareInstance) and
  allowsCredentials(corsMiddlewareInstance) and
  containsInsecureOrigin(corsMiddlewareInstance.getOrigins().getALocalSource())
}

// 查询存在安全风险的CORS中间件配置
from Http::Server::CorsMiddleware corsMiddlewareInstance
where hasVulnerableCorsConfiguration(corsMiddlewareInstance)
select corsMiddlewareInstance,
  "This CORS middleware configuration allows authenticated cross-origin requests from any source, potentially exposing sensitive data"