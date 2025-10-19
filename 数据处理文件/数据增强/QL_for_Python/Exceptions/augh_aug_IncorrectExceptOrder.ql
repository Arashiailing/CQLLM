/**
 * @name Unreachable 'except' block
 * @description Handling general exceptions before specific exceptions means that the specific
 *              handlers are never executed.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       external/cwe/cwe-561
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unreachable-except
 */

import python

// 检测异常处理顺序问题：当父类异常处理块位于子类异常处理块之前时
predicate hasExceptOrderIssue(ExceptStmt prevHandler, ClassValue generalException, 
                             ExceptStmt nextHandler, ClassValue narrowException) {
  exists(int prevIndex, int nextIndex, Try tryBlock |
    // 确定两个异常处理块属于同一个try语句
    prevHandler = tryBlock.getHandler(prevIndex) and
    nextHandler = tryBlock.getHandler(nextIndex) and
    // 验证处理块顺序（先出现的在前）
    prevIndex < nextIndex and
    // 获取异常类型
    prevHandler.getType().pointsTo(generalException) and
    nextHandler.getType().pointsTo(narrowException) and
    // 检查异常类型继承关系（父类异常处理在前）
    generalException = narrowException.getASuperType()
  )
}

// 查找所有不可达的异常处理块
from ExceptStmt laterHandler, ClassValue specificException, 
     ExceptStmt earlierHandler, ClassValue broaderException
where hasExceptOrderIssue(earlierHandler, broaderException, 
                         laterHandler, specificException)
select laterHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificException, specificException.getName(), earlierHandler, "except block", broaderException, broaderException.getName()