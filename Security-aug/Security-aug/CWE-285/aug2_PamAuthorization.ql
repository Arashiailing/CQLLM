/**
 * @name PAM授权绕过问题由于不正确使用
 * @description 检测在调用`pam_authenticate`后未执行`pam_acct_mgmt`验证登录有效性的场景，
 *              这种缺陷可能导致未授权访问（CWE-285: 不当授权）
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

// 从PAM授权流图中提取存在数据流路径的源节点和目标节点
from PamAuthorizationFlow::PathNode originNode, PamAuthorizationFlow::PathNode targetNode
// 验证源节点到目标节点存在完整的数据流路径
where PamAuthorizationFlow::flowPath(originNode, targetNode)
// 输出目标节点位置、数据流路径起始点、目标节点及详细警告信息
select targetNode.getNode(), originNode, targetNode,
  "此PAM认证流程依赖 $@，但后续未调用'pam_acct_mgmt'进行有效性验证",
  originNode.getNode(), "用户提供值"