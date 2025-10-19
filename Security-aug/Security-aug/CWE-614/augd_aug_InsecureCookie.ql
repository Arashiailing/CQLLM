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

// 识别cookie安全配置中的具体缺陷类型及其优先级
predicate identifiesCookieSecurityFlaw(Http::Server::CookieWrite cookieSetting, string flawCategory, int flawPriority) {
  // 检测未启用Secure标志的安全缺陷
  cookieSetting.hasSecureFlag(false) and
  flawCategory = "Secure" and
  flawPriority = 0
  or
  // 检测未启用HttpOnly标志的安全缺陷
  cookieSetting.hasHttpOnlyFlag(false) and
  flawCategory = "HttpOnly" and
  flawPriority = 1
  or
  // 检测SameSite设置为None的安全缺陷
  cookieSetting.hasSameSiteAttribute(any(Http::Server::CookieWrite::SameSiteNone v)) and
  flawCategory = "SameSite" and
  flawPriority = 2
}

// 构建针对cookie安全缺陷的警告文本
predicate constructSecurityWarning(Http::Server::CookieWrite cookieSetting, string warningText) {
  // 计算当前cookie存在的安全缺陷总数
  exists(int flawCount | 
    flawCount = strictcount(string flaw | identifiesCookieSecurityFlaw(cookieSetting, flaw, _)) |
    // 根据缺陷数量生成不同格式的警告消息
    flawCount = 1 and
    warningText = any(string f | identifiesCookieSecurityFlaw(cookieSetting, f, _)) + " attribute"
    or
    flawCount = 2 and
    warningText =
      strictconcat(string f, int priority | 
        identifiesCookieSecurityFlaw(cookieSetting, f, priority) | 
        f, " and " order by priority
      ) + " attributes"
    or
    flawCount = 3 and
    warningText = "Secure, HttpOnly, and SameSite attributes"
  )
}

// 查询存在安全缺陷的cookie设置并生成相应警告
from Http::Server::CookieWrite cookieSetting, string warningText
where constructSecurityWarning(cookieSetting, warningText)
select cookieSetting, "Cookie is added without the " + warningText + " properly set."