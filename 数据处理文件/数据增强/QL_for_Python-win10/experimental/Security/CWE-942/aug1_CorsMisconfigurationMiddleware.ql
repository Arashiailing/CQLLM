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

/**
 * 检查节点是否包含通配符配置（星号或null字符串）
 * 支持两种形式：列表元素或直接字符串字面量
 */
predicate hasWildcardConfiguration(DataFlow::Node configNode) {
  // 检查列表类型节点中是否包含通配符元素
  exists(List listExpr | listExpr = configNode.asExpr() |
    exists(StringLiteral wildcard | wildcard = listExpr.getASubExpression() |
      wildcard.getText() in ["*", "null"]
    )
  )
  or
  // 检查字符串字面量节点是否为通配符
  exists(StringLiteral wildcard | wildcard = configNode.asExpr() |
    wildcard.getText() in ["*", "null"]
  )
}

// 重构主查询逻辑，合并中间谓词条件
from Http::Server::CorsMiddleware middleware
where
  // 直接内联中间件类型检查
  middleware.getMiddlewareName() = "CORSMiddleware" and
  // 直接内联凭证权限检查
  middleware.getCredentialsAllowed().asExpr() instanceof True and
  // 使用重命名后的谓词检查来源配置
  hasWildcardConfiguration(middleware.getOrigins().getALocalSource())
select middleware,
  "This CORS middleware uses a vulnerable configuration that allows arbitrary websites to make authenticated cross-site requests"