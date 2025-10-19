/**
 * @name PAM授权绕过漏洞
 * @description 当使用`pam_authenticate`函数进行认证后，未调用`pam_acct_mgmt`来验证账户有效性时，
 *              可能导致授权机制被绕过，使未授权用户获得访问权限。
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

// 定义PAM认证流程中的起点和终点
from PamAuthorizationFlow::PathNode authSource, PamAuthorizationFlow::PathNode authSink
// 确保存在从认证起点到终点的数据流路径
where PamAuthorizationFlow::flowPath(authSource, authSink)
// 输出结果：认证终点、起点、路径以及相关警告信息
select authSink.getNode(), authSource, authSink,
  "此PAM认证依赖于$@，但后续未调用'pam_acct_mgmt'进行账户有效性验证。",
  authSource.getNode(), "用户提供的输入值"