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

// 检查CORS来源配置是否为不安全的通配符或空值字符串
predicate hasInsecureStringValue(DataFlow::Node corsOriginNode) {
  exists(StringLiteral originValue |
    originValue = corsOriginNode.asExpr() and
    originValue.getText() in ["*", "null"]
  )
}

// 检查CORS来源配置列表是否包含不安全的通配符或空值元素
predicate hasInsecureListValue(DataFlow::Node corsOriginNode) {
  exists(List originList | originList = corsOriginNode.asExpr() |
    exists(StringLiteral originValue |
      originValue = originList.getASubExpression() and
      originValue.getText() in ["*", "null"]
    )
  )
}

// 组合检查CORS来源配置是否包含不安全的值
predicate containsInsecureOrigin(DataFlow::Node corsOriginNode) {
  hasInsecureStringValue(corsOriginNode) or
  hasInsecureListValue(corsOriginNode)
}

// 验证中间件是否为CORS类型中间件
predicate isCorsTypeMiddleware(Http::Server::CorsMiddleware corsMiddleware) {
  corsMiddleware.getMiddlewareName() = "CORSMiddleware"
}

// 检查中间件是否配置为支持凭证
predicate allowsCredentials(Http::Server::CorsMiddleware corsMiddleware) {
  corsMiddleware.getCredentialsAllowed().asExpr() instanceof True
}

// 检查是否存在安全风险的CORS中间件配置组合
predicate hasVulnerableCorsConfiguration(Http::Server::CorsMiddleware corsMiddleware) {
  allowsCredentials(corsMiddleware) and
  containsInsecureOrigin(corsMiddleware.getOrigins().getALocalSource()) and
  isCorsTypeMiddleware(corsMiddleware)
}

// 查询存在安全风险的CORS中间件配置
from Http::Server::CorsMiddleware corsMiddleware
where hasVulnerableCorsConfiguration(corsMiddleware)
select corsMiddleware,
  "This CORS middleware configuration allows authenticated cross-origin requests from any source, potentially exposing sensitive data"