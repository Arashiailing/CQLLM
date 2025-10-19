/**
 * @name 'break' or 'return' statement in finally
 * @description 检测在 finally 块中使用 break 或 return 语句的情况。
 *              这些语句会导致 try-finally 块提前退出，从而可能抑制异常。
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

// 查询主体：查找在 finally 块中的问题语句
from Stmt stmtInFinally, string statementType
where
  // 情况1：在 finally 块中的 return 语句
  (
    stmtInFinally instanceof Return and 
    statementType = "return" and 
    exists(Try tryStatement | tryStatement.getFinalbody().contains(stmtInFinally))
  )
  or
  // 情况2：在 finally 块中的 break 语句，且不在任何循环内
  (
    stmtInFinally instanceof Break and 
    statementType = "break" and 
    exists(Try tryStatement | 
      tryStatement.getFinalbody().contains(stmtInFinally) and
      // 确保 break 语句不在任何循环内（既不在 for 循环也不在 while 循环中）
      not exists(For loopStatement | 
        loopStatement.contains(stmtInFinally) and 
        tryStatement.getFinalbody().contains(loopStatement)
      ) and
      not exists(While loopStatement | 
        loopStatement.contains(stmtInFinally) and 
        tryStatement.getFinalbody().contains(loopStatement)
      )
    )
  )
// 输出结果：问题语句及其警告信息
select stmtInFinally, "'" + statementType + "' in a finally block will swallow any exceptions raised."