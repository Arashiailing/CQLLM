/**
 * @name CWE-522: Insufficiently Protected Credentials
 * @description nan
 * @id py/views-cwe-522
 */

import python // 导入Python库，用于处理Python代码的查询
import semmle.python.dataflow.new.DataFlow // 导入数据流分析模块，用于跟踪数据流路径
import semmle.python.Concepts // 导入Python概念模块，提供一些基本的Python编程概念

// 定义一个谓词函数，用于判断是否存在不安全的cookie设置问题
predicate hasProblem(Http::Server::CookieWrite cookie, string alert, int idx) {
  // 如果cookie没有设置Secure标志，则返回警告信息"Secure"和索引0
  cookie.hasSecureFlag(false) and
  alert = "Secure" and
  idx = 0
  or
  // 如果cookie没有设置HttpOnly标志，则返回警告信息"HttpOnly"和索引1
  cookie.hasHttpOnlyFlag(false) and