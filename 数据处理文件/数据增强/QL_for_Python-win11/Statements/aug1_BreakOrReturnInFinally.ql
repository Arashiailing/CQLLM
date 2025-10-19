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

// 定义查询主体：查找在finally块中的问题语句
from Stmt problematicStmt, string stmtType
where
  // 情况1：finally块中的return语句
  (
    problematicStmt instanceof Return and 
    stmtType = "return" and 
    exists(Try enclosingTry | enclosingTry.getFinalbody().contains(problematicStmt))
  )
  or
  // 情况2：finally块中的break语句（不在循环内）
  (
    problematicStmt instanceof Break and 
    stmtType = "break" and 
    exists(Try enclosingTry | 
      enclosingTry.getFinalbody().contains(problematicStmt) and
      // 确保break语句不在任何循环内（既不在for循环也不在while循环中）
      not exists(For enclosingLoop | 
        enclosingLoop.contains(problematicStmt) and 
        enclosingTry.getFinalbody().contains(enclosingLoop)
      ) and
      not exists(While enclosingLoop | 
        enclosingLoop.contains(problematicStmt) and 
        enclosingTry.getFinalbody().contains(enclosingLoop)
      )
    )
  )
// 输出结果：问题语句及其警告信息
select problematicStmt, "'" + stmtType + "' in a finally block will swallow any exceptions raised."