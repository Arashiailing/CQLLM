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

// 查找PAM授权流程中的潜在绕过路径
// 起点节点表示认证开始位置，终点节点表示未进行账户管理的位置
from PamAuthorizationFlow::PathNode flowOrigin, PamAuthorizationFlow::PathNode flowDestination
// 检查是否存在从认证起点到终点的完整数据流路径
// 这种路径表明存在授权绕过风险，因为未调用pam_acct_mgmt进行账户验证
where 
  // 验证起点到终点存在完整的数据流路径
  PamAuthorizationFlow::flowPath(flowOrigin, flowDestination)
// 输出检测结果：风险位置、起点、终点及问题描述
select flowDestination.getNode(), flowOrigin, flowDestination,
  "This PAM authentication depends on a $@, and 'pam_acct_mgmt' is not called afterwards.",
  flowOrigin.getNode(), "user-provided value"