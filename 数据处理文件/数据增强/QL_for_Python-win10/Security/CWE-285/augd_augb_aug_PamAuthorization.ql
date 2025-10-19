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

// 定义PAM授权流程的起点（认证入口）和终点（潜在漏洞点）
from PamAuthorizationFlow::PathNode authStart, PamAuthorizationFlow::PathNode vulnSink
// 验证是否存在从认证入口到漏洞点的完整授权流程路径
where PamAuthorizationFlow::flowPath(authStart, vulnSink)
// 生成安全警告报告，包含漏洞位置、路径起点和详细描述
select vulnSink.getNode(), authStart, vulnSink,
  "PAM认证流程存在缺陷：依赖$@进行认证，但后续未调用'pam_acct_mgmt'验证账户有效性",
  authStart.getNode(), "用户提供的认证凭据"