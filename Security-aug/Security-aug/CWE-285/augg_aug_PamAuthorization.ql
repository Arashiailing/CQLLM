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

// 定义授权流程的起点和终点变量
from PamAuthorizationFlow::PathNode authStartNode, PamAuthorizationFlow::PathNode authEndNode
// 检查是否存在从起点到终点的完整授权流程路径
where PamAuthorizationFlow::flowPath(authStartNode, authEndNode)
// 选择结果并生成警告消息，指出PAM认证依赖于用户提供的值且之后未调用pam_acct_mgmt
select authEndNode.getNode(), authStartNode, authEndNode,
  "This PAM authentication depends on a $@, and 'pam_acct_mgmt' is not called afterwards.",
  authStartNode.getNode(), "user-provided value"