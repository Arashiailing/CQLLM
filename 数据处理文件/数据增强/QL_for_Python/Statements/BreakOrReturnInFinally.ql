/**
 * @name 'break' or 'return' statement in finally
 * @description 在finally块中使用Break或Return语句会导致Try-finally块退出，并丢弃异常。
 * @kind problem
 * @tags reliability
 *       maintainability
 *       external/cwe/cwe-584
 * @problem.severity warning
 * @sub-severity low
 * @precision medium
 * @id py/exit-from-finally
 */

import python

// 从Stmt s和字符串kind中选择数据
from Stmt s, string kind
where
  // 如果s是Return实例并且kind为"return"，且存在一个Try t使得t的finalbody包含s
  s instanceof Return and kind = "return" and exists(Try t | t.getFinalbody().contains(s))
  or
  // 如果s是Break实例并且kind为"break"，且存在一个Try t使得t的finalbody包含s
  s instanceof Break and
  kind = "break" and
  exists(Try t | t.getFinalbody().contains(s) |
    // 并且不存在一个For循环loop使得loop包含s且t的finalbody包含loop
    not exists(For loop | loop.contains(s) and t.getFinalbody().contains(loop)) and
    // 并且不存在一个While循环loop使得loop包含s且t的finalbody包含loop
    not exists(While loop | loop.contains(s) and t.getFinalbody().contains(loop))
  )
// 选择s，并返回警告信息："'kind' in a finally block will swallow any exceptions raised."
select s, "'" + kind + "' in a finally block will swallow any exceptions raised."
