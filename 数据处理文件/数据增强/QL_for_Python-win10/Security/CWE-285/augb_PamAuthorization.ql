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

// 定义PAM授权流程中的源节点（认证入口）和汇节点（潜在绕过点）
from PamAuthorizationFlow::PathNode authSource, PamAuthorizationFlow::PathNode authSink
// 检查是否存在从认证入口到潜在绕过点的数据流路径
where PamAuthorizationFlow::flowPath(authSource, authSink)
// 输出结果：汇节点位置、源节点位置、汇节点位置及安全警告信息
select authSink.getNode(), authSource, authSink,
  "This PAM authentication depends on a $@, and 'pam_acct_mgmt' is not called afterwards.",
  authSource.getNode(), "user-provided value"