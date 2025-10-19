/**
 * @name PAM授权绕过漏洞
 * @description 检测PAM认证流程中，在调用`pam_authenticate`函数完成用户身份验证后，
 *              未调用`pam_acct_mgmt`函数进行账户有效性验证的安全缺陷。这种缺陷可能导致
 *              未经验证的账户获得系统访问权限，形成授权绕过漏洞。
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

// 定义PAM认证流程的起始节点和终止节点
from PamAuthorizationFlow::PathNode authStartNode, PamAuthorizationFlow::PathNode authEndNode

// 验证从认证起点到终点是否存在完整的数据流路径
// 该路径表示pam_authenticate被调用但未调用pam_acct_mgmt进行账户验证
where 
  PamAuthorizationFlow::flowPath(authStartNode, authEndNode)

// 输出检测结果，标识存在授权绕过风险的代码位置
// 报告格式包含起点、终点和描述信息
select authEndNode.getNode(), authStartNode, authEndNode,
  "PAM认证流程中存在$@，且后续未调用'pam_acct_mgmt'进行账户有效性验证。",
  authStartNode.getNode(), "用户输入值"