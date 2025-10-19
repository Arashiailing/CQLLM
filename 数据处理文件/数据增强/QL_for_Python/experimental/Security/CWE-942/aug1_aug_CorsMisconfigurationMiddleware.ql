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

// 检查CORS来源配置是否包含不安全的通配符或空值
predicate containsInsecureOrigin(DataFlow::Node originSetting) {
  // 情况1：来源配置为列表且包含 "*" 或 "null" 元素
  exists(List listExpr | listExpr = originSetting.asExpr() |
    exists(StringLiteral strLit |
      strLit = listExpr.getASubExpression() and
      strLit.getText() in ["*", "null"]
    )
  )
  // 情况2：来源配置直接为 "*" 或 "null" 字符串
  or
  exists(StringLiteral strLit |
    strLit = originSetting.asExpr() and
    strLit.getText() in ["*", "null"]
  )
}

// 验证中间件是否为CORS类型中间件
predicate isCorsTypeMiddleware(Http::Server::CorsMiddleware corsMid) {
  corsMid.getMiddlewareName() = "CORSMiddleware"
}

// 检查中间件是否配置为支持凭证
predicate allowsCredentials(Http::Server::CorsMiddleware corsMid) {
  corsMid.getCredentialsAllowed().asExpr() instanceof True
}

// 查询存在安全风险的CORS中间件配置组合
from Http::Server::CorsMiddleware corsMid
where
  // 安全风险条件组合：凭证支持 + 不安全来源配置 + CORS中间件验证
  allowsCredentials(corsMid) and
  containsInsecureOrigin(corsMid.getOrigins().getALocalSource()) and
  isCorsTypeMiddleware(corsMid)
select corsMid,
  // 安全风险说明：允许任意来源的认证请求可能导致敏感数据泄露
  "This CORS middleware configuration allows authenticated cross-origin requests from any source, potentially exposing sensitive data"