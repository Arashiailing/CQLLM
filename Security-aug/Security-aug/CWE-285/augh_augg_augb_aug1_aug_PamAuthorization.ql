/**
 * @name PAM授权绕过漏洞
 * @description 检测PAM认证实现中的安全缺陷：当系统调用`pam_authenticate`完成身份验证后，
 *              未能正确调用`pam_acct_mgmt`函数验证账户有效性，可能导致未授权访问。
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

// 检测PAM认证流程中的潜在授权绕过路径
from PamAuthorizationFlow::PathNode authStartNode, PamAuthorizationFlow::PathNode authEndNode
// 确认存在从认证起点到终点的完整数据流，表明缺少账户验证步骤
where PamAuthorizationFlow::flowPath(authStartNode, authEndNode)
// 输出检测结果，标识存在授权绕过风险的代码位置及路径
select authEndNode.getNode(), authStartNode, authEndNode,
  "检测到PAM认证流程存在$@，但缺少后续的'pam_acct_mgmt'账户有效性验证调用。",
  authStartNode.getNode(), "用户认证凭据"