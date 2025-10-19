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

// 查找在finally块中导致异常被丢弃的退出语句
from Stmt exitStmt, string stmtType
where
  // 检查finally块中的return语句（无条件视为问题）
  (
    exitStmt instanceof Return 
    and stmtType = "return"
    and exists(Try enclosingTry | enclosingTry.getFinalbody().contains(exitStmt))
  )
  or
  // 检查finally块中的break语句（仅当不在循环内时视为问题）
  (
    exitStmt instanceof Break 
    and stmtType = "break"
    and exists(Try enclosingTry | 
      enclosingTry.getFinalbody().contains(exitStmt)
      // 确保break语句不在任何循环结构内
      and not exists(For forStmt | 
        forStmt.contains(exitStmt) 
        and enclosingTry.getFinalbody().contains(forStmt)
      )
      and not exists(While whileStmt | 
        whileStmt.contains(exitStmt) 
        and enclosingTry.getFinalbody().contains(whileStmt)
      )
    )
  )
// 返回问题语句及警告信息
select exitStmt, "'" + stmtType + "' in a finally block will swallow any exceptions raised."