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

// 查找在 finally 块中使用 break 或 return 语句的情况
from Stmt problematicStmt, string statementType
where
  (
    // 检查是否为 return 语句且位于 finally 块中
    problematicStmt instanceof Return and 
    statementType = "return" and 
    exists(Try tryFinally | tryFinally.getFinalbody().contains(problematicStmt))
  )
  or
  // 检查是否为 break 语句且位于 finally 块中，且不在循环内
  (
    problematicStmt instanceof Break and 
    statementType = "break" and 
    exists(Try tryFinally | 
      tryFinally.getFinalbody().contains(problematicStmt) and
      // 确保 break 语句不在 For 循环中
      not exists(For forLoop | 
        forLoop.contains(problematicStmt) and 
        tryFinally.getFinalbody().contains(forLoop)
      ) and
      // 确保 break 语句不在 While 循环中
      not exists(While whileLoop | 
        whileLoop.contains(problematicStmt) and 
        tryFinally.getFinalbody().contains(whileLoop)
      )
    )
  )
// 选择有问题的语句，并返回警告信息
select problematicStmt, "'" + statementType + "' in a finally block will swallow any exceptions raised."