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

// 定义PAM授权流程的源节点和汇节点
from PamAuthorizationFlow::PathNode sourceNode, PamAuthorizationFlow::PathNode sinkNode
// 验证从源节点到汇节点存在完整的数据流路径，表明存在授权绕过风险
where 
  PamAuthorizationFlow::flowPath(sourceNode, sinkNode)
// 输出检测结果：风险位置、源节点、汇节点及问题描述
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode,
  "This PAM authentication depends on a $@, and 'pam_acct_mgmt' is not called afterwards.",
  sourceNode.getNode(), 
  "user-provided value"