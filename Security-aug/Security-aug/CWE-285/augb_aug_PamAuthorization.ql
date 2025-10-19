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

// 定义授权流程的起点（认证入口）和终点（潜在漏洞点）
from PamAuthorizationFlow::PathNode authEntryPoint, PamAuthorizationFlow::PathNode vulnSinkPoint
// 验证是否存在从认证入口到漏洞点的完整授权流程路径
where PamAuthorizationFlow::flowPath(authEntryPoint, vulnSinkPoint)
// 生成安全警告报告
select vulnSinkPoint.getNode(), authEntryPoint, vulnSinkPoint,
  "This PAM authentication depends on a $@, and 'pam_acct_mgmt' is not called afterwards.",
  authEntryPoint.getNode(), "user-provided value"