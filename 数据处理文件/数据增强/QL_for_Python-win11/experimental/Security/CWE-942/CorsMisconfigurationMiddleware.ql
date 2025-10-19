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

// 定义一个谓词函数，用于检查数组是否包含星号或null字符串
predicate containsStar(DataFlow::Node array) {
  // 检查数组表达式是否是列表类型，并且其子表达式是字符串字面量且值为"*"或"null"
  array.asExpr() instanceof List and
  array.asExpr().getASubExpression().(StringLiteral).getText() in ["*", "null"]
  // 或者数组表达式本身是字符串字面量且值为"*"或"null"
  or
  array.asExpr().(StringLiteral).getText() in ["*", "null"]
}

// 定义一个谓词函数，用于判断给定的中间件是否是CORS中间件
predicate isCorsMiddleware(Http::Server::CorsMiddleware middleware) {
  // 检查中间件的名称是否为"CORSMiddleware"
  middleware.getMiddlewareName() = "CORSMiddleware"
}

// 定义一个谓词函数，用于判断给定的CORS中间件是否允许凭证
predicate credentialsAllowed(Http::Server::CorsMiddleware middleware) {
  // 检查中间件的凭证允许属性是否为True
  middleware.getCredentialsAllowed().asExpr() instanceof True
}

// 从所有CORS中间件中选择满足特定条件的中间件
from Http::Server::CorsMiddleware a
where
  // 条件1：中间件允许凭证
  credentialsAllowed(a) and
  // 条件2：中间件的来源包含星号或null字符串
  containsStar(a.getOrigins().getALocalSource()) and
  // 条件3：中间件是CORS中间件
  isCorsMiddleware(a)
select a,
  // 输出警告信息，说明该CORS中间件使用了不安全的配置，允许任意网站进行跨站请求
  "This CORS middleware uses a vulnerable configuration that allows arbitrary websites to make authenticated cross-site requests"
