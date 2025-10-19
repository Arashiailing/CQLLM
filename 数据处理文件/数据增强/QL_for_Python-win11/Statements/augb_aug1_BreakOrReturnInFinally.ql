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

// 查询主体：识别finally块中的问题语句
from Stmt offendingStmt, string statementType
where
  // 情况1：finally块中的return语句
  (
    offendingStmt instanceof Return and 
    statementType = "return" and 
    exists(Try enclosingTryStmt | 
      enclosingTryStmt.getFinalbody().contains(offendingStmt)
    )
  )
  or
  // 情况2：finally块中的break语句（且不在循环内）
  (
    offendingStmt instanceof Break and 
    statementType = "break" and 
    exists(Try enclosingTryStmt | 
      enclosingTryStmt.getFinalbody().contains(offendingStmt) and
      // 确保break语句不在任何循环内（既不在for循环也不在while循环中）
      not exists(Stmt enclosingLoopStmt | 
        (enclosingLoopStmt instanceof For or enclosingLoopStmt instanceof While) and
        enclosingLoopStmt.contains(offendingStmt) and 
        enclosingTryStmt.getFinalbody().contains(enclosingLoopStmt)
      )
    )
  )
// 输出结果：问题语句及其警告信息
select offendingStmt, "'" + statementType + "' in a finally block will swallow any exceptions raised."