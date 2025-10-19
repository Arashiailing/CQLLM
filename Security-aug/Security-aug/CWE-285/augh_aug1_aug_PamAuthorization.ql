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

// 识别PAM授权流程中的潜在安全漏洞
// 查找从认证起点到终点的数据流路径，其中缺少对'pam_acct_mgmt'的调用，
// 这可能导致攻击者绕过授权检查
from PamAuthorizationFlow::PathNode authOrigin, PamAuthorizationFlow::PathNode authTermination
// 验证是否存在从认证起点到终点的完整数据流路径
// 如果存在这样的路径，则表明可能存在授权绕过风险
where PamAuthorizationFlow::flowPath(authOrigin, authTermination)
// 输出检测结果，标识存在授权绕过风险的代码位置
// 报告中包含起点和终点信息，以便开发者定位问题
select authTermination.getNode(), authOrigin, authTermination,
  "This PAM authentication depends on a $@, and 'pam_acct_mgmt' is not called afterwards.",
  authOrigin.getNode(), "user-provided value"