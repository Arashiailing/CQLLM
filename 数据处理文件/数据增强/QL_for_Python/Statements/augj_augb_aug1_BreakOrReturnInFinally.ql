/**
 * @name 'break' or 'return' statement in finally
 * @description 检测在finally块中使用break或return语句的情况，这些语句会导致Try-finally块异常退出并丢弃原有异常。
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

// 主查询：定位finally块中的问题语句
from Stmt problematicStmt, string stmtType
where
  // 检测场景1：finally块中的return语句
  (
    problematicStmt instanceof Return and 
    stmtType = "return" and 
    exists(Try enclosingTry | 
      enclosingTry.getFinalbody().contains(problematicStmt)
    )
  )
  or
  // 检测场景2：finally块中的break语句（且不在循环内）
  (
    problematicStmt instanceof Break and 
    stmtType = "break" and 
    exists(Try enclosingTry | 
      enclosingTry.getFinalbody().contains(problematicStmt) and
      // 确认break语句不在任何循环结构内（既不在for循环也不在while循环中）
      not exists(Stmt enclosingLoop | 
        (enclosingLoop instanceof For or enclosingLoop instanceof While) and
        enclosingLoop.contains(problematicStmt) and 
        enclosingTry.getFinalbody().contains(enclosingLoop)
      )
    )
  )
// 输出格式：问题语句及相应警告信息
select problematicStmt, "'" + stmtType + "' in a finally block will swallow any exceptions raised."