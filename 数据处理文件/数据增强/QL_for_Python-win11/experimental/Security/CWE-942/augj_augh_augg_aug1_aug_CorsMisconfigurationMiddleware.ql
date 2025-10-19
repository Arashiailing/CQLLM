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
predicate containsInsecureOrigin(DataFlow::Node corsOriginNode) {
  // 情况1: 检查直接字符串值是否为不安全的通配符或空值
  exists(StringLiteral insecureOriginLiteral |
    insecureOriginLiteral = corsOriginNode.asExpr() and
    insecureOriginLiteral.getText() in ["*", "null"]
  )
  or
  // 情况2: 检查列表配置中是否包含不安全的通配符或空值元素
  exists(List originListNode | originListNode = corsOriginNode.asExpr() |
    exists(StringLiteral insecureOriginLiteral |
      insecureOriginLiteral = originListNode.getASubExpression() and
      insecureOriginLiteral.getText() in ["*", "null"]
    )
  )
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
  isCorsTypeMiddleware(corsMiddleware) and
  allowsCredentials(corsMiddleware) and
  containsInsecureOrigin(corsMiddleware.getOrigins().getALocalSource())
}

// 查询存在安全风险的CORS中间件配置
from Http::Server::CorsMiddleware vulnerableCorsMiddleware
where hasVulnerableCorsConfiguration(vulnerableCorsMiddleware)
select vulnerableCorsMiddleware,
  "This CORS middleware configuration allows authenticated cross-origin requests from any source, potentially exposing sensitive data"