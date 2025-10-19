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

// 查找PAM授权流程的起始点和结束点
from PamAuthorizationFlow::PathNode authStartPoint, PamAuthorizationFlow::PathNode authEndPoint
// 验证是否存在从认证起点到终点的完整数据流路径
where PamAuthorizationFlow::flowPath(authStartPoint, authEndPoint)
// 输出检测结果，标识存在授权绕过风险的代码位置
select authEndPoint.getNode(), authStartPoint, authEndPoint,
  "This PAM authentication depends on a $@, and 'pam_acct_mgmt' is not called afterwards.",
  authStartPoint.getNode(), "user-provided value"