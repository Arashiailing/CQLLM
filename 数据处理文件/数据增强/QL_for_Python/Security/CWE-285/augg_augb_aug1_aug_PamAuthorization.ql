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

// 定义PAM认证流程的起始节点和终止节点
from PamAuthorizationFlow::PathNode authenticationStartNode, PamAuthorizationFlow::PathNode authenticationEndNode
// 验证从认证起始点到终止点是否存在完整的数据流路径
where 
  exists(PamAuthorizationFlow::PathNode start, PamAuthorizationFlow::PathNode end |
    start = authenticationStartNode and 
    end = authenticationEndNode and 
    PamAuthorizationFlow::flowPath(start, end)
  )
// 输出检测结果，标识存在授权绕过风险的代码位置
select authenticationEndNode.getNode(), authenticationStartNode, authenticationEndNode,
  "PAM认证流程中存在$@，且后续未调用'pam_acct_mgmt'进行账户有效性验证。",
  authenticationStartNode.getNode(), "用户输入值"