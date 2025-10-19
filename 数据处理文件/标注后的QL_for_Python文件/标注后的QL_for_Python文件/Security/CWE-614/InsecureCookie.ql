/**
 * @name Failure to use secure cookies
 * @description Insecure cookies may be sent in cleartext, which makes them vulnerable to
 *              interception.
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

// 定义一个谓词函数，用于判断是否存在不安全的cookie设置问题
predicate hasProblem(Http::Server::CookieWrite cookie, string alert, int idx) {
  // 如果cookie没有设置Secure标志，则返回警告信息"Secure"和索引0
  cookie.hasSecureFlag(false) and
  alert = "Secure" and
  idx = 0
  or
  // 如果cookie没有设置HttpOnly标志，则返回警告信息"HttpOnly"和索引1
  cookie.hasHttpOnlyFlag(false) and
  alert = "HttpOnly" and
  idx = 1
  or
  // 如果cookie的SameSite属性设置为None，则返回警告信息"SameSite"和索引2
  cookie.hasSameSiteAttribute(any(Http::Server::CookieWrite::SameSiteNone v)) and
  alert = "SameSite" and
  idx = 2
}

// 定义一个谓词函数，用于生成最终的警告信息
predicate hasAlert(Http::Server::CookieWrite cookie, string alert) {
  // 计算存在多少个不安全设置的问题
  exists(int numProblems | numProblems = strictcount(string p | hasProblem(cookie, p, _)) |
    // 如果只有一个问题，则直接使用该问题的警告信息并加上" attribute"
    numProblems = 1 and
    alert = any(string prob | hasProblem(cookie, prob, _)) + " attribute"
    or
    // 如果有两个问题，则将两个问题的警告信息用" and "连接起来，并加上" attributes"
    numProblems = 2 and
    alert =
      strictconcat(string prob, int idx | hasProblem(cookie, prob, idx) | prob, " and " order by idx)
        + " attributes"
    or
    // 如果有三个问题，则直接返回固定的警告信息
    numProblems = 3 and
    alert = "Secure, HttpOnly, and SameSite attributes"
  )
}

// 查询语句：查找所有存在不安全cookie设置的cookie，并生成相应的警告信息
from Http::Server::CookieWrite cookie, string alert
where hasAlert(cookie, alert)
select cookie, "Cookie is added without the " + alert + " properly set."
