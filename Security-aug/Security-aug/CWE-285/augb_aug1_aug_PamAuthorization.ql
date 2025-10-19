/**
 * @name PAM授权绕过漏洞
 * @description 当PAM认证流程中，在调用`pam_authenticate`后未调用`pam_acct_mgmt`进行账户有效性验证时，可能导致授权绕过。
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

// 定义PAM认证流程的起点和终点节点
from PamAuthorizationFlow::PathNode pamAuthStart, PamAuthorizationFlow::PathNode pamAuthEnd
// 验证认证起点到终点是否存在完整数据流路径
where PamAuthorizationFlow::flowPath(pamAuthStart, pamAuthEnd)
// 输出检测结果，标识存在授权绕过风险的代码位置
select pamAuthEnd.getNode(), pamAuthStart, pamAuthEnd,
  "PAM认证流程中存在$@，且后续未调用'pam_acct_mgmt'进行账户有效性验证。",
  pamAuthStart.getNode(), "用户输入值"