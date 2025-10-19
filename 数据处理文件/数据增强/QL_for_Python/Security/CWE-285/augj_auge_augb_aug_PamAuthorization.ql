/**
 * @name PAM授权绕过问题由于不正确使用
 * @description 检测在`pam_authenticate`认证后未调用`pam_acct_mgmt`验证账户有效性的场景，
 *              此缺陷可能导致未授权访问（CWE-285）
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

// 定义关键节点：认证入口点与潜在漏洞点
from PamAuthorizationFlow::PathNode authEntry, PamAuthorizationFlow::PathNode vulnSink
// 验证授权流程路径完整性：从认证入口到漏洞点存在完整数据流
where PamAuthorizationFlow::flowPath(authEntry, vulnSink)
// 生成漏洞报告，包含路径追踪和问题描述
select vulnSink.getNode(), authEntry, vulnSink,
  "PAM认证依赖$@，但后续未调用'pam_acct_mgmt'进行账户有效性验证",
  authEntry.getNode(), "用户提供的凭证值"