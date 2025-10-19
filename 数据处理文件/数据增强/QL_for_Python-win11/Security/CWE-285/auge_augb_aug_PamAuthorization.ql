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

// 定义授权流程的起始节点（认证操作入口）和终止节点（潜在漏洞点）
from PamAuthorizationFlow::PathNode authenticationStartNode, PamAuthorizationFlow::PathNode vulnerabilitySinkNode
// 验证是否存在从认证入口到漏洞点的完整授权流程路径
where PamAuthorizationFlow::flowPath(authenticationStartNode, vulnerabilitySinkNode)
// 生成安全警告报告
select vulnerabilitySinkNode.getNode(), authenticationStartNode, vulnerabilitySinkNode,
  "This PAM authentication depends on a $@, and 'pam_acct_mgmt' is not called afterwards.",
  authenticationStartNode.getNode(), "user-provided value"