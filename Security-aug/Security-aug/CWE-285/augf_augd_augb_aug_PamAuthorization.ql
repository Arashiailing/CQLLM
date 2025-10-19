/**
 * @name PAM授权绕过漏洞
 * @description 检测在调用`pam_authenticate`函数后，未正确使用`pam_acct_mgmt`函数验证账户有效性的情况，这可能导致授权被绕过的安全风险。
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

/**
 * 本查询检测PAM授权流程中的安全漏洞：
 * 1. 识别代码中的认证入口点（调用pam_authenticate的位置）
 * 2. 识别可能存在漏洞的点（未调用pam_acct_mgmt的位置）
 * 3. 验证两者之间是否存在数据流路径
 * 4. 报告潜在的安全风险
 */
from PamAuthorizationFlow::PathNode authenticationEntry, PamAuthorizationFlow::PathNode vulnerabilityPoint
where 
  // 检查是否存在从认证入口到漏洞点的完整授权流程路径
  PamAuthorizationFlow::flowPath(authenticationEntry, vulnerabilityPoint)
select 
  vulnerabilityPoint.getNode(), 
  authenticationEntry, 
  vulnerabilityPoint,
  "PAM授权流程存在安全缺陷：系统依赖$@进行用户认证，但未在后续流程中调用'pam_acct_mgmt'函数验证账户有效性，可能导致授权被绕过",
  authenticationEntry.getNode(), 
  "用户提供的认证凭据"