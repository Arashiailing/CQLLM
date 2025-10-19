/**
 * @name PAM授权绕过问题由于不正确使用
 * @description 在`pam_authenticate`之后不使用`pam_acct_mgmt`来检查登录的有效性，可能导致授权绕过。
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 8.1
 * @precision high
 * @id py/pam-auth-bypass
 * @tags security
 *       external/cwe/cwe-285
 */

import python
import PamAuthorizationFlow::PathGraph
import semmle.python.ApiGraphs
import semmle.python.security.dataflow.PamAuthorizationQuery

// 定义PAM授权流程的起点和终点节点
from PamAuthorizationFlow::PathNode authFlowStart, PamAuthorizationFlow::PathNode authFlowEnd
// 验证是否存在从起点到终点的完整授权流程路径
where PamAuthorizationFlow::flowPath(authFlowStart, authFlowEnd)
// 输出结果并生成安全警告消息
select authFlowEnd.getNode(), authFlowStart, authFlowEnd,
  "This PAM authentication depends on a $@, and 'pam_acct_mgmt' is not called afterwards.",
  authFlowStart.getNode(), "user-provided value"