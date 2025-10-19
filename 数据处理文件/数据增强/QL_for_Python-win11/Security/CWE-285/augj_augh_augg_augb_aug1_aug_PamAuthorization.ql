/**
 * @name PAM授权绕过漏洞
 * @description 识别PAM认证实现中的安全弱点：当系统通过`pam_authenticate`函数完成用户身份认证后，
 *              没有正确调用`pam_acct_mgmt`函数来验证账户的有效状态，可能导致未授权的访问风险。
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

// 识别PAM认证流程中可能存在的授权绕过路径
from PamAuthorizationFlow::PathNode credentialVerificationNode, PamAuthorizationFlow::PathNode authCompletionNode
where PamAuthorizationFlow::flowPath(credentialVerificationNode, authCompletionNode)
// 展示检测结果，标记存在授权绕过风险的代码位置及完整路径
select authCompletionNode.getNode(), credentialVerificationNode, authCompletionNode,
  "发现PAM认证流程中存在$@，但未执行必要的'pam_acct_mgmt'账户有效性验证。",
  credentialVerificationNode.getNode(), "用户认证凭据"