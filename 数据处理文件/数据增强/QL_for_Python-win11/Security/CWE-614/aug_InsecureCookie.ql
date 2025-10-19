/**
 * @name Failure to use secure cookies
 * @description Insecure cookies may be transmitted in cleartext, making them vulnerable to
 *              interception and manipulation.
 * @kind problem
 * @problem.severity warning
 * @security-severity 5.0
 * @precision high
 * @id py/insecure-cookie
 * @tags security
 *       external/cwe/cwe-614
 *       external/cwe/cwe-1004
 *       external/cwe/cwe-1275
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.Concepts

// 检测cookie安全配置缺陷，返回缺陷类型和优先级索引
predicate hasSecurityDefect(Http::Server::CookieWrite cookie, string defectType, int priorityIndex) {
  // 未启用Secure标志时标记为安全缺陷
  cookie.hasSecureFlag(false) and
  defectType = "Secure" and
  priorityIndex = 0
  or
  // 未启用HttpOnly标志时标记为安全缺陷
  cookie.hasHttpOnlyFlag(false) and
  defectType = "HttpOnly" and
  priorityIndex = 1
  or
  // SameSite设置为None时标记为安全缺陷
  cookie.hasSameSiteAttribute(any(Http::Server::CookieWrite::SameSiteNone v)) and
  defectType = "SameSite" and
  priorityIndex = 2
}

// 生成针对cookie安全缺陷的警告消息
predicate generateSecurityAlert(Http::Server::CookieWrite cookie, string alertMessage) {
  // 统计当前cookie存在的安全缺陷数量
  exists(int defectCount | 
    defectCount = strictcount(string defect | hasSecurityDefect(cookie, defect, _)) |
    // 根据缺陷数量生成不同格式的警告
    defectCount = 1 and
    alertMessage = any(string d | hasSecurityDefect(cookie, d, _)) + " attribute"
    or
    defectCount = 2 and
    alertMessage =
      strictconcat(string d, int idx | 
        hasSecurityDefect(cookie, d, idx) | 
        d, " and " order by idx
      ) + " attributes"
    or
    defectCount = 3 and
    alertMessage = "Secure, HttpOnly, and SameSite attributes"
  )
}

// 查询存在安全缺陷的cookie设置并生成警告
from Http::Server::CookieWrite cookie, string alertMessage
where generateSecurityAlert(cookie, alertMessage)
select cookie, "Cookie is added without the " + alertMessage + " properly set."