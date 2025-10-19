/**
 * @name CORS Misconfiguration with Credentials
 * @description Identifies insecure CORS configurations where wildcard origins
 *              are combined with credential support, risking data exposure.
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

// 检测包含通配符或空值的来源配置节点
predicate hasInsecureOriginConfig(DataFlow::Node originNode) {
  exists(StringLiteral originValue |
    (
      originValue = originNode.asExpr() or
      originValue = originNode.asExpr().(List).getASubExpression()
    ) and
    originValue.getText() in ["*", "null"]
  )
}

// 定位存在凭证泄露风险的CORS配置
from Http::Server::CorsMiddleware corsConfig
where
  // 验证中间件类型为CORS
  corsConfig.getMiddlewareName() = "CORSMiddleware" and
  // 确认凭证支持已启用
  corsConfig.getCredentialsAllowed().asExpr() instanceof True and
  // 检测来源配置存在安全风险
  hasInsecureOriginConfig(corsConfig.getOrigins().getALocalSource())
select corsConfig,
  "This CORS configuration permits authenticated requests from arbitrary origins, creating potential data exposure risks"